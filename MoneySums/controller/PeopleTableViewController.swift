//
//  PeopleTableViewController.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2021/09/07.
//

import DVPieChart
import LocalAuthentication
import RealmSwift
import SwiftUI
import UIKit

class PeopleTableViewController: UITableViewController {
    private var pieSliceOrdering = 0
    let realm = UIApplication.getRealm()

    var people: Results<Person>?
    var nameTextField: UITextField?
    @IBOutlet var lastDataLoadTime: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorInset = UIEdgeInsets.zero
        UITableViewHeaderFooterView.appearance().tintColor = UIColor.adaTeal

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshControlAction), for: .valueChanged)

        hideKeyboardWhenTappedAround()

        showAuthorizationOverlay(promptUserAuth: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        loadPeople()
    }

    @objc func refreshControlAction() {
        pieSliceOrdering = 0
        loadPeople()
    }

    func updateLoadTime() {
        lastDataLoadTime.text = "Last load @ \(Date().hms())"
        refreshControl?.endRefreshing()
    }

    @IBAction func addPerson(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(
            title: "Add a person",
            message: "someone you have money relationship with.",
            preferredStyle: .alert
        )

        alert.addTextField(configurationHandler: nameTextField)
        alert.addAction(UIAlertAction(title: "save", style: .default, handler: savePerson))
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        alert.applyNoEmptyValidation()
        present(alert, animated: true)
    }

    func savePerson(_ uiAlertAction: UIAlertAction) {
        let person = Person()
        person.name = nameTextField!.text!
        do {
            try realm.write {
                realm.add(person)
            }
        } catch {
            print("failed to save a person: \(error)")
        }
        tableView.reloadData(completion: updateLoadTime)
    }

    func nameTextField(_ textField: UITextField) {
        textField.accessibilityIdentifier = "person\(UIAlertController.ValidationIdFlag.nonEmpty)"
        textField.autocapitalizationType = .words
        textField.autocorrectionType = .default
        textField.textContentType = .givenName
        nameTextField = textField
    }

    func loadPeople() {
        people = realm.objects(Person.self).sorted(byKeyPath: "name", ascending: true)
        cleanOldPaidAmounts()
        tableView.reloadData(completion: updateLoadTime)
        if people?.count ?? 0 <= 0 {
            AuthorizationOverlay.shared.hideOverlayView()
        }
    }

    func cleanOldPaidAmounts() {
        let retentionMonths = UserDefaults.standard.getPaidAmountRetentionMonths()
        if retentionMonths > 0 {
            DispatchQueue.main.async {
                self.people?.flatMap { $0.amounts }
                    .filter { $0.wasPaidMoreThan(monthsAgo: retentionMonths) }
                    .forEach { amount in
                        print("Value \(amount.moneyValue) note: \(amount.note) isPaid: \(amount.isPaid)")
                        do {
                            try self.realm.write {
                                self.realm.delete(amount.payments)
                                self.realm.delete(amount)
                            }

                            self.tableView.reloadData()
                        } catch {
                            print("auto-deleting an amount failed, error: \(error)")
                        }
                    }
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return (people?.count ?? 0) > 0 ? 2 : 1
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if (people?.count ?? 0) > 0 {
            switch section {
            case 0:
                let total = people?.reduce(0.0) { $0 + $1.totalUnpaid }
                return "total: \((total ?? 0.0).moneyFormattedString())"
            case 1:
                return "Distribution Chart"
            default:
                return nil
            }
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? super.tableView(tableView, heightForRowAt: indexPath) : CGFloat(UIScreen.main.bounds.width * 1.2)
    }

    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let footer: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        footer.textLabel?.text = footer.textLabel?.text?.uppercased()
        footer.textLabel?.textAlignment = .right
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let row = tableView.dequeueReusableCell(withIdentifier: "personRow", for: indexPath)

            if (people?.count ?? 0) > 0 {
                let person = people?[indexPath.row]

                row.accessoryType = .disclosureIndicator
                row.textLabel?.text = person?.name.capitalized
//                row.textLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)

                row.detailTextLabel?.text = person?.moneyDescription
                row.detailTextLabel?.textColor = (person?.totalUnpaid ?? 0) == 0 ? UIColor.adaAccentColor : (person?.totalUnpaid ?? 0 > 0) ? UIColor.adaOrange : UIColor.adaTeal
            } else {
                row.accessoryType = .none

                row.textLabel?.text = "press + to add a person"
                row.textLabel?.textColor = UIColor.label
                row.textLabel?.font = UIFont.systemFont(ofSize: 16.0)

                row.detailTextLabel?.text = "swipe right to delete the person"
                row.detailTextLabel?.textColor = UIColor.secondaryLabel
            }
            return row
        } else {
            let row = tableView.dequeueReusableCell(withIdentifier: "chartRow", for: indexPath)
            let chartView = row.contentView.subviews.first as! DVPieChart
            customizeChart(chartView: chartView)
            return row
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let peopleCount = people?.count ?? 0
        return (section == 1) ? 1 : (peopleCount > 0) ? peopleCount : 1
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if (people?.count ?? 0) > 0 {
                performSegue(withIdentifier: "showAmounts", sender: self)
            } else {
                tableView.deselectRow(at: indexPath, animated: true)
                tableView.cellForRow(at: indexPath)?.shake()
            }
        } else {
            updateChartSliceOrdering()
            tableView.beginUpdates()
            tableView.reloadRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }

    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if people?.count ?? 0 > 0, let person = people?[indexPath.row] {
            if indexPath.section == 0 && person.totalUnpaid == 0 {
                let deletionAction = UIContextualAction(style: .destructive, title: "delete") { _, _, isActionSuccessful in
                    let alert = UIAlertController(
                        title: "Confirm",
                        message: "You really want to delete \(person.name)?",
                        preferredStyle: .alert
                    )

                    alert.addAction(
                        UIAlertAction(
                            title: "Yes",
                            style: .destructive,
                            handler: { _ in
                                DispatchQueue.main.async {
                                    isActionSuccessful(true)
                                    self.deletePerson(at: indexPath)
                                }
                            }
                        )
                    )
                    alert.addAction(
                        UIAlertAction(
                            title: "Cancel",
                            style: .cancel,
                            handler: { _ in
                                isActionSuccessful(false)
                                self.tableView.cellForRow(at: indexPath)?.shake()
                            }
                        )
                    )

                    self.present(alert, animated: true)
                }

                deletionAction.image = UIImage(systemName: "trash")
                let config = UISwipeActionsConfiguration(actions: [deletionAction])
                config.performsFirstActionWithFullSwipe = true

                return config
            }
        }
        self.tableView.cellForRow(at: indexPath)?.shake()
        return nil
    }

    func deletePerson(at indexPath: IndexPath) {
        do {
            let wasLastPerson = people?.count == 1
            try realm.write {
                self.realm.delete(self.people![indexPath.row].amounts)
                self.realm.delete(self.people![indexPath.row])
            }

            if wasLastPerson {
                tableView.deleteSections([1], with: .fade)
            } else {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            tableView.endUpdates()
            tableView.reloadData(completion: updateLoadTime)
        } catch {
            print("error deleting person at row: \(indexPath.row), error: \(error)")
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? AmountTableViewController {
            if let selectedRowIndexPath = tableView.indexPathForSelectedRow {
                destinationViewController.selectedPerson = people?[selectedRowIndexPath.row]
            }
        }

        if let appConfigController = segue.destination as? AppConfigViewController {
            appConfigController.appLockDelegate = self
            if let sheet = appConfigController.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.largestUndimmedDetentIdentifier = .none
                sheet.prefersEdgeAttachedInCompactHeight = true
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
                sheet.prefersGrabberVisible = true
            }
        }
    }
}

// MARK: SearchBar delegate methods

extension PeopleTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            loadPeople()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            if searchText.isEmpty {
                loadPeople()
            } else {
                people = people?.filter("name CONTAINS[cd] %@", searchText).sorted(byKeyPath: "name", ascending: true)
                tableView.reloadData(completion: updateLoadTime)
            }
        }
    }

    // MARK: - Chart datasource

    func updateChartSliceOrdering() {
        pieSliceOrdering = (pieSliceOrdering + 1) % 5
    }

    func customizeChart(chartView: DVPieChart) {
        if let people = people?.filter({ $0.totalUnpaid != 0.0 }) {
            let amountsSum = people.reduce(0.0) {
                $0 + abs($1.totalUnpaid)
            }

            var dataEntries: [DVPieSliceModel] = []
            for person in people {
                let m = DVPieSliceModel()
                m.name = person.firstName
                m.rate = abs(person.totalUnpaid) / amountsSum
                dataEntries.append(m)
            }

            switch pieSliceOrdering {
            case 0: dataEntries.sort { $0.rate < $1.rate }
                break
            case 1: dataEntries.sort { $0.rate > $1.rate }
                break
            default:
                dataEntries.shuffle()
            }

            chartView.sliceNameColor = UIColor.adaAccentColor
            chartView.pieCenterCirclePercentage = 1.2
            chartView.dataArray = dataEntries
            chartView.clipsToBounds = true
            chartView.sizeToFit()
            chartView.title = self.people?.count ?? 0 > 0 ?
                (dataEntries.count > 0 ?
                    "μ°" :
                    " press a persons name to manage their amounts ") :
                " press + to add a person "
            chartView.draw()
        }
    }
}

// MARK: - App info

extension PeopleTableViewController: AppLockDelegate {
    func lockNow() {
        showAuthorizationOverlay()
    }

    private func showAuthorizationOverlay(promptUserAuth: Bool = false) {
        AuthorizationOverlay.shared.showOverlay(isDarkModeEnabled: traitCollection.userInterfaceStyle == .dark, doAuthPrompt: promptUserAuth)
    }
}
