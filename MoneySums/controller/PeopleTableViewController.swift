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
    let realm = try! Realm(configuration: Realm.Configuration(schemaVersion: 2))
    var people: Results<Person>?
    var nameTextField: UITextField?
    @IBOutlet var lastDataLoadTime: UILabel!
    let APP_ICON_KEY = "AppIcon"

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshAppIcon()

        tableView.separatorInset = UIEdgeInsets.zero
        UITableViewHeaderFooterView.appearance().tintColor = UIColor.adaTeal

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshControlAction), for: .valueChanged)

        showAuthorizationOverlay()
    }

    override func viewWillAppear(_ animated: Bool) {
        loadPeople()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    @objc func refreshControlAction() {
        pieSliceOrdering = (pieSliceOrdering + 1) % 3
        loadPeople()
    }

    func updateLoadTime() {
        lastDataLoadTime.text = "Last load :\(pieSliceOrdering) @ \(Date().hms())"
        refreshControl?.endRefreshing()
    }

    @IBAction func showAppInfoPressed(_ sender: UIBarButtonItem) {
        showAppInfo()
    }

    @IBAction func addPerson(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(
            title: "add a person",
            message: "someone you have money relationship with.",
            preferredStyle: .alert
        )

        alert.addTextField(configurationHandler: nameTextField)
        alert.addAction(UIAlertAction(title: "save", style: .default, handler: savePerson))
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))

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
        textField.autocapitalizationType = .words
        textField.autocorrectionType = .default
        textField.textContentType = .givenName
        nameTextField = textField
    }

    func loadPeople() {
        people = realm.objects(Person.self).sorted(byKeyPath: "name", ascending: true)
        tableView.reloadData(completion: updateLoadTime)
        if people?.count ?? 0 <= 0 {
            AuthorizationOverlay.shared.hideOverlayView()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            let total = people?.reduce(0.0) {
                $0 + $1.totalUnpaid
            }
            return "total: \((total ?? 0.0).moneyFormattedString())"
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
            let person = people?[indexPath.row]

            row.accessoryType = .disclosureIndicator
            row.textLabel?.text = person?.name.capitalized
            row.textLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)

            row.detailTextLabel?.text = person?.totalUnpaid.moneyFormattedString()
            row.detailTextLabel?.textColor = (person?.totalUnpaid ?? 0) == 0 ? UIColor.adaAccentColor : (person?.totalUnpaid ?? 0 > 0) ? UIColor.adaTeal : UIColor.adaOrange

            return row
        } else {
            let row = tableView.dequeueReusableCell(withIdentifier: "chartRow", for: indexPath)
            let chartView = row.contentView.subviews.first as! DVPieChart
            customizeChart(chartView: chartView)
            return row
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 1 ? 1 : people?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if (people?.count ?? 0) > 0 {
                performSegue(withIdentifier: "showAmounts", sender: self)
            } else {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 0 && people?[indexPath.row].totalUnpaid == 0 {
            let deletionAction = UIContextualAction(style: .destructive, title: "delete") { _, _, isActionSuccessful in
                isActionSuccessful(true)
                self.deletePerson(at: indexPath)
            }

            deletionAction.image = UIImage(systemName: "trash")
            let config = UISwipeActionsConfiguration(actions: [deletionAction])

            config.performsFirstActionWithFullSwipe = people?[indexPath.row].totalUnpaid == 0
            return config
        }
        return nil
    }

    func deletePerson(at indexPath: IndexPath) {
        do {
            try realm.write {
                self.realm.delete(self.people![indexPath.row].amounts)
                self.realm.delete(self.people![indexPath.row])
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            tableView.reloadData(completion: updateLoadTime)
        } catch {
            print("error deleting person at row: \(indexPath.row), error: \(error)")
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination as! AmountTableViewController
        if let selectedRowIndexPath = tableView.indexPathForSelectedRow {
            destinationViewController.selectedPerson = people?[selectedRowIndexPath.row]
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
          DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.refreshAppIcon()
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

    private func showAuthorizationOverlay() {
        AuthorizationOverlay.shared.showOverlay(isDarkModeEnabled: traitCollection.userInterfaceStyle == .dark)
    }

    // MARK: - App info

    func showAppInfo() {
        let alert = UIAlertController(
            title: "\(Bundle.main.appName)",
            message: "Version \(Bundle.main.appVersion) (\(Bundle.main.appBuild))\nUsed frameworks:\n\u{2022}DVPieChart\n\u{2022}RealmSwift",
            preferredStyle: .actionSheet
        )

        alert.addAction(UIAlertAction(title: "Use Dark App Icon", style: .default, handler: { _ in self.setAppIconChoice(0) }))
        alert.addAction(UIAlertAction(title: "Use Light App Icon", style: .default, handler: { _ in self.setAppIconChoice(1) }))
        alert.addAction(UIAlertAction(title: "Auto Set App Icon", style: .default, handler: { _ in self.setAppIconChoice(2) }))
        alert.addAction(UIAlertAction(title: "LOCK APP", style: .destructive, handler: { _ in self.showAuthorizationOverlay() }))
        alert.addAction(UIAlertAction(title: "EXIT", style: .cancel, handler: nil))

        let checkmark = UIImage(systemName: "checkmark")
        alert.actions[UserDefaults.standard.integer(forKey: APP_ICON_KEY)].setValue(checkmark?.withRenderingMode(.automatic), forKey: "image")
        present(alert, animated: true)
    }
}

// MARK: App icon settings

extension PeopleTableViewController {
    func setAppIconChoice(_ choice: Int) {
        UserDefaults.standard.set(choice, forKey: APP_ICON_KEY)
        refreshAppIcon()
    }

    func refreshAppIcon() {
        if #available(iOS 13, *) {
            switch UserDefaults.standard.integer(forKey: APP_ICON_KEY) {
            case 0: self.clearAltIcon(); break
            case 1: self.setLightIcon(); break
            default: self.autoSetIconForCurrentUiTrait()
            }
        }
    }

    func autoSetIconForCurrentUiTrait() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if self.traitCollection.userInterfaceStyle == .dark {
                self.clearAltIcon()
            } else if UIApplication.shared.alternateIconName != "lightMode" {
                self.setLightIcon()
            }
        }
    }

    func setLightIcon() {
        if UIApplication.shared.alternateIconName != "lightMode" {
            UIApplication.shared.setAlternateIconName("lightMode") { error in
                if let clearError = error {
                    print("Failed to set the alternative app icon name: \(clearError)")
                }
            }
        }
    }

    func clearAltIcon() {
        if UIApplication.shared.alternateIconName != nil {
            UIApplication.shared.setAlternateIconName(nil) { error in
                if let clearError = error {
                    print("Failed to clear the alternative app icon name: \(clearError)")
                }
            }
        }
    }
}
