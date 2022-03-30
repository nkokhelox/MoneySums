//
//  ViewController.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2021/08/08.
//

import DVPieChart
import LocalAuthentication
import RealmSwift
import UIKit

class AmountTableViewController: UITableViewController {
    private let realm = UIApplication.getRealm()

    private var paidAmounts: Results<Amount>?
    private var unpaidAmounts: Results<Amount>?
    private var sectionExpansionState: [Bool] = [false, true, false]

    private var selectedAmountIndexPath: IndexPath?
    private var noteTextField: UITextField?
    private var amountTextField: UITextField?
    private var paymentTextField: UITextField?
    private var paymentNoteTextField: UITextField?

    @IBOutlet var lastDataLoadTime: UILabel!

    var selectedPerson: Person? {
        didSet {
            self.title = selectedPerson?.name.truncate(maxLength: 15, withEllipsis: true).capitalized
            self.loadAmounts()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorInset = UIEdgeInsets.zero

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadAmounts), for: .valueChanged)

        hideKeyboardWhenTappedAround()
    }

    @IBAction func addAmount(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(
            title: "Add a money record",
            message: "negative amount if you owe them.",
            preferredStyle: .alert
        )

        alert.addTextField(configurationHandler: amountTextField)
        alert.addTextField(configurationHandler: noteTextField)

        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: saveAmount))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.applyIsNumberValidation()
        present(alert, animated: true)
    }

    @objc func loadAmounts() {
        unpaidAmounts = selectedPerson?.amounts.filter("datePaid == nil").sorted(by: [SortDescriptor(keyPath: "dateCreated", ascending: true), SortDescriptor(keyPath: "value", ascending: false)])
        paidAmounts = selectedPerson?.amounts.filter("datePaid != nil").sorted(byKeyPath: "dateCreated", ascending: false)
        tableView.reloadData(completion: updateLoadTime)
        sectionExpansionState[1] = (paidAmounts?.count ?? 0) > 5
    }

    func updateLoadTime() {
        lastDataLoadTime.text = "Last load @ \(Date().hms())"
        refreshControl?.endRefreshing()
    }
}

// MARK: Add amount alert methods

extension AmountTableViewController {
    func amountTextField(textField: UITextField) {
        amountTextField = textField
        textField.accessibilityIdentifier = "amount\(UIAlertController.ValidationIdFlag.isNumber)"
        textField.keyboardType = .decimalPad
        textField.returnKeyType = .next
        textField.placeholder = 0.0.moneyFormattedString()
        textField.addNumericAccessory(addPlusMinus: true)
    }

    func noteTextField(textField: UITextField) {
        noteTextField = textField
        textField.placeholder = "add some note about this amount"
        textField.autocapitalizationType = .sentences
        textField.autocorrectionType = .default
        textField.textContentType = .givenName
    }

    func saveAmount(action: UIAlertAction) {
        let amount = Amount(
            value: amountTextField!.text!.trimmingCharacters(in: .whitespaces).toDoubleOption()!,
            note: noteTextField!.text!.trimmingCharacters(in: .whitespaces)
        )

        if let person = selectedPerson {
            do {
                try realm.write {
                    person.amounts.append(amount)
                }
            } catch {
                print("error saving the amount for \(person.name): \(error)")
            }
        }

        tableView.reloadData(completion: updateLoadTime)
    }
}

// MARK: Add payment alert methods

extension AmountTableViewController {
    func addPayment() {
        if let indexPath = selectedAmountIndexPath {
            var amount: Amount {
                (indexPath.section == 0 ? unpaidAmounts : paidAmounts)![indexPath.row]
            }

            let alert = UIAlertController(
                title: "add payment for \(amount.moneyValue)",
                message: amount.note.truncate(maxLength: 200, withEllipsis: true),
                preferredStyle: .alert
            )

            alert.addTextField(configurationHandler: paymentTextField)
            alert.addTextField(configurationHandler: paymentNoteTextField)

            alert.addAction(UIAlertAction(title: "save", style: .default, handler: savePayment))
            alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
            alert.applyIsNumberValidation()

            present(alert, animated: true)
        }
    }

    func paymentTextField(textField: UITextField) {
        paymentTextField = textField
        textField.keyboardType = .decimalPad
        textField.returnKeyType = .done
        textField.placeholder = 0.0.moneyFormattedString()
        textField.addNumericAccessory(addPlusMinus: true)
        textField.accessibilityIdentifier = "payment\(UIAlertController.ValidationIdFlag.isNumber)"
    }

    func paymentNoteTextField(textField: UITextField) {
        paymentNoteTextField = textField
        textField.placeholder = "add some note about this amount"
        textField.autocapitalizationType = .sentences
        textField.autocorrectionType = .default
        textField.textContentType = .givenName
    }

    func savePayment(action: UIAlertAction) {
        if let indexPath = selectedAmountIndexPath {
            let interest = Payment(
                value: paymentTextField!.text!.toDoubleOption()!,
                note: paymentNoteTextField?.text ?? ""
            )

            do {
                try realm.write {
                    (indexPath.section == 0 ? unpaidAmounts : paidAmounts)![indexPath.row].payments.append(interest)
                }
            } catch {
                print("error saving the amount for \(selectedPerson!.name): \(error)")
            }

            tableView.reloadData(completion: updateLoadTime)
        }
    }

    func showAmountInfo(_ indexPath: IndexPath) {
        let amount = (indexPath.section == 0 ? unpaidAmounts : paidAmounts)![indexPath.row]
        let alert = UIAlertController(
            title: amount.value.moneyFormattedString(),
            message: amount.fullDetailText,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in self.tableView.reloadData(completion: self.updateLoadTime) }))

        present(alert, animated: true)
    }
}

// MARK: TableView DataSource methods

extension AmountTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 2 ? CGFloat(UIScreen.main.bounds.width) : super.tableView(tableView, heightForRowAt: indexPath)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return ((selectedPerson?.amounts.count ?? 0) == 0) ? 1 : sectionExpansionState.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return ((selectedPerson?.amounts.count ?? 0) == 0) ? 1 : sectionExpansionState[section] ? 0 : (unpaidAmounts?.count ?? 1)
        case 1:
            return sectionExpansionState[section] ? 0 : paidAmounts?.count ?? 0
        default:
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 2 {
            let row = tableView.dequeueReusableCell(withIdentifier: "chartRow", for: indexPath)
            let chartView = row.contentView.subviews.first as! DVPieChart
            customizeChart(chartView: chartView)
            return row
        } else {
            let row = tableView.dequeueReusableCell(withIdentifier: "amountRow", for: indexPath)

            let longPress = RowLongPress(indexPath: indexPath, target: self, action: #selector(onRowLongPress(_:)))
            row.addGestureRecognizer(longPress)

            if (selectedPerson?.amounts.count ?? 0) == 0 {
                row.textLabel?.text = "press + to add amount"
                row.textLabel?.textColor = UIColor.label
                row.textLabel?.font = UIFont.systemFont(ofSize: 16.0)

                row.detailTextLabel?.text = "swipe left or right to do more with the amount"
                row.detailTextLabel?.textColor = UIColor.secondaryLabel

                row.accessoryType = .none
            } else {
                let amount = (indexPath.section == 0 ? unpaidAmounts : paidAmounts)?[indexPath.row]
                let diff = amount!.paymentsTotal - amount!.value

                row.accessoryType = amount?.isPaid == true ? .checkmark : .detailButton
                row.accessoryView?.backgroundColor = .red

                row.textLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
                row.textLabel?.text = amount?.moneyValue

                row.detailTextLabel?.textColor = diff == 0 ? UIColor.secondaryLabel : diff > 0 ? UIColor.adaOrange : UIColor.adaTeal
                row.detailTextLabel?.text = amount?.detailText
            }
            return row
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section < 2 {
            if (selectedPerson?.amounts.count ?? 0) == 0 {
                tableView.cellForRow(at: indexPath)?.shake()
            } else {
                let amounts = (indexPath.section == 0 ? unpaidAmounts : paidAmounts)
                if amounts?[indexPath.row].payments.count == 0 {
                    showAmountInfo(indexPath)
                } else {
                    performSegue(withIdentifier: "showPayments", sender: self)
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        showAmountInfo(indexPath)
    }
}

// MARK: Tableview row swipe action methods

extension AmountTableViewController {
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 2 || (selectedPerson?.amounts.count ?? 0) == 0 {
            return nil
        }

        let amount = (indexPath.section == 0 ? unpaidAmounts : paidAmounts)![indexPath.row]
        let actionTitle = amount.isPaid ? "unpaid" : "paid"
        let paidToggleAction = UIContextualAction(style: .normal, title: actionTitle) { _, _, isActionSuccessful in
            isActionSuccessful(true)
            do {
                try self.realm.write {
                    amount.datePaid = amount.isPaid ? nil : Date()
                }
            } catch {
                print("error toggling the paid status for \(amount.moneyValue)")
            }

            tableView.reloadData(completion: self.updateLoadTime)
        }

        paidToggleAction.image = UIImage(systemName: amount.isPaid ? "xmark" : "checkmark")
        paidToggleAction.backgroundColor = UIColor.adaOrange

        var swipeActions: [UIContextualAction] = [paidToggleAction]

        let addPaymentAction = UIContextualAction(style: .normal, title: "payment") { _, _, isActionSuccessful in
            self.selectedAmountIndexPath = indexPath
            isActionSuccessful(true)
            self.addPayment()
        }

        addPaymentAction.image = UIImage(systemName: "text.badge.plus")
        addPaymentAction.backgroundColor = UIColor.adaTeal
        swipeActions.append(addPaymentAction)

        let config = UISwipeActionsConfiguration(actions: swipeActions)
        config.performsFirstActionWithFullSwipe = false

        return config
    }

    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 2 || (selectedPerson?.amounts.count ?? 0) == 0 {
            return nil
        }

        let amount = (indexPath.section == 0 ? unpaidAmounts : paidAmounts)![indexPath.row]

        let deletionAction = UIContextualAction(style: .destructive, title: "delete") { _, _, isActionSuccessful in

            let alert = UIAlertController(
                title: "Confirm",
                message: "You really want to delete \(amount.moneyValue)?",
                preferredStyle: .alert
            )

            alert.addAction(
                UIAlertAction(
                    title: "Yes",
                    style: .destructive,
                    handler: { _ in
                        DispatchQueue.main.async {
                            isActionSuccessful(true)
                            self.deleteAmount(at: indexPath)
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

        deletionAction.image = UIImage(systemName: "trash.fill")

        let config = UISwipeActionsConfiguration(actions: [deletionAction])
        config.performsFirstActionWithFullSwipe = true

        return config
    }

    func deleteAmount(at indexPath: IndexPath) {
        let amount = (indexPath.section == 0 ? unpaidAmounts : paidAmounts)![indexPath.row]
        let wasLastAmount = selectedPerson?.amounts.count == 1
        let wasPaid = amount.isPaid

        do {
            try realm.write {
                self.realm.delete(amount.payments)
                self.realm.delete(amount)
            }

            tableView.beginUpdates()
            if wasLastAmount {
                tableView.deleteSections([1, 2], with: .fade)
                if wasPaid {
                    tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                }
            } else {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            tableView.endUpdates()
            tableView.reloadData()
        } catch {
            tableView.cellForRow(at: indexPath)?.shake()
            print("error deleting amount at row: \(indexPath.row), error: \(error)")
        }
    }
}

// MARK: - Headers and Footers

extension AmountTableViewController {
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (selectedPerson?.amounts.count ?? 0) == 0 {
            return nil
        }

        let expansionIndicator = sectionExpansionState[section] ? "⌄" : "›"
        return section == 2 ?
            nil : section == 0 ?
            "unpaid (\(unpaidAmounts?.count ?? 0)) \(expansionIndicator)" : "paid (\(paidAmounts?.count ?? 0)) \(expansionIndicator)"
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if (selectedPerson?.amounts.count ?? 0) == 0 {
            return nil
        }

        let totalMoney = (section == 0 ? selectedPerson?.totalUnpaid : selectedPerson?.totalPaid) ?? 0.0
        return section == 2 ? "Distribution Chart" : "total \(totalMoney.moneyFormattedString())"
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.textLabel?.textAlignment = .right
        header.addGestureRecognizer(OnSectionHeaderFooterTap(section: section, target: self, action: #selector(tapHeader(_:))))
    }

    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let footer: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        footer.textLabel?.text = footer.textLabel?.text?.uppercased()
        footer.textLabel?.textAlignment = .right
    }
}

// MARK: - Gesture recogniser

extension AmountTableViewController {
    @objc func tapHeader(_ sender: UIGestureRecognizer) {
        if let headerTapEvent = sender as? OnSectionHeaderFooterTap {
            sectionExpansionState[headerTapEvent.section].toggle()
            tableView.reloadData()
        }
    }

    @objc func onRowLongPress(_ sender: UILongPressGestureRecognizer) {
        if let event = sender as? RowLongPress {
            tableView.deselectRow(at: event.indexPath, animated: true)
            switch event.indexPath.section {
            case 0, 1:
                showAmountInfo(event.indexPath)
            default:
                return
            }
        }
    }
}

// MARK: - Navigation

extension AmountTableViewController {
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            if let destinationViewController = segue.destination as? PaymentTableViewController {
                let amounts = (indexPath.section == 0 ? unpaidAmounts : paidAmounts)

                destinationViewController.onDismiss = { [weak self] in self?.tableView.reloadData(completion: self!.updateLoadTime) }
                destinationViewController.selectedAmount = amounts![indexPath.row]

                tableView.deselectRow(at: indexPath, animated: true)

                if let sheet = destinationViewController.sheetPresentationController {
                    sheet.detents = [.large()]
                    sheet.largestUndimmedDetentIdentifier = .none
                    sheet.prefersGrabberVisible = true
                    sheet.prefersEdgeAttachedInCompactHeight = true
                    sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                    sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
                }
            }
        }
    }
}

// MARK: SearchBar delegate methods

extension AmountTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            loadAmounts()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            if searchText.isEmpty {
                loadAmounts()
            } else {
                paidAmounts = paidAmounts?.filter("note CONTAINS[cd] %@", searchText).sorted(byKeyPath: "dateCreated", ascending: false)
                unpaidAmounts = unpaidAmounts?.filter("note CONTAINS[cd] %@", searchText).sorted(byKeyPath: "dateCreated", ascending: true)
                tableView.reloadData(completion: updateLoadTime)
            }
        }
    }

    // MARK: - Chart datasource

    func customizeChart(chartView: DVPieChart) {
        let youOweMeTotal = unpaidAmounts?.filter { $0.paymentsDifference < 0.0 }.reduce(0.0) {
            $0 + abs($1.paymentsDifference)
        } ?? 0.0

        let iOweYouTotal = unpaidAmounts?.filter { $0.paymentsDifference > 0.0 }.reduce(0.0) {
            $0 + abs($1.paymentsDifference)
        } ?? 0.0

        let amountsTotal = youOweMeTotal + iOweYouTotal

        var dataEntries: [DVPieSliceModel] = []

        if amountsTotal > 0 {
            let iouSlice = DVPieSliceModel()
            iouSlice.name = "I.O.U (\(iOweYouTotal.moneyFormattedString()))"
            iouSlice.value = iOweYouTotal
            iouSlice.rate = iOweYouTotal / amountsTotal
            dataEntries.append(iouSlice)

            let uomSlice = DVPieSliceModel()
            uomSlice.name = "U.O.Me (\(youOweMeTotal.moneyFormattedString()))"
            uomSlice.value = youOweMeTotal
            uomSlice.rate = youOweMeTotal / amountsTotal
            dataEntries.append(uomSlice)
        }

        dataEntries = dataEntries.filter { $0.rate != 0.0 }

        chartView.sliceNameColor = UIColor.adaAccentColor
        chartView.pieCenterCirclePercentage = 1.2
        chartView.dataArray = dataEntries
        chartView.clipsToBounds = true
        chartView.sizeToFit()
        chartView.title = dataEntries.count > 0 ? "μ°" : "Everything is paid up for `\(selectedPerson!.firstName)`."
        chartView.draw()
    }
}
