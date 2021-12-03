//
//  PaymentTableViewController.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2021/09/11.
//

import LocalAuthentication
import RealmSwift
import UIKit

class PaymentTableViewController: UITableViewController {
    let realm = try! Realm(configuration: Realm.Configuration(schemaVersion: 2))

    var onDismiss: (() -> Void)?

    @IBOutlet var footNote: UILabel!
    @IBOutlet var dragPill: UIImageView!

    var payments: List<Payment>?

    var selectedAmount: Amount? {
        didSet {
            loadPayments()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        footNote.text = selectedAmount?.paymentsDetailText.uppercased()
        footNote.alpha = (selectedAmount?.paymentsDifference ?? 0) == 0 ? 0.3 : 0.5
        footNote.textColor = (selectedAmount?.paymentsDifference ?? 0) == 0 ? UIColor.adaAccentColor :
            (selectedAmount?.paymentsTotal ?? 0 > 0) ? UIColor.adaOrange : UIColor.adaTeal

        dragPill.backgroundColor = (selectedAmount?.paymentsTotal ?? 0 > 0) ? UIColor.adaOrange : UIColor.adaTeal

        tableView.separatorInset = UIEdgeInsets.zero
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onDismiss?()
    }

    func loadPayments() {
        payments = selectedAmount?.payments
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedAmount?.payments.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = tableView.dequeueReusableCell(withIdentifier: "interestRow", for: indexPath)
        row.textLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        row.textLabel?.text = selectedAmount?.payments[indexPath.row].moneyValue
        row.detailTextLabel?.text = selectedAmount?.payments[indexPath.row].paidDate.niceDescription()
        return row
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let count = payments?.count ?? 0
        let prefix = count > 1 ? "\(count) payments" : "payment"
        return "\(prefix) for \(selectedAmount!.moneyValue)"
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "total \(selectedAmount!.paymentsTotal.moneyFormattedString())"
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.textLabel?.textAlignment = .right
    }

    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let footer: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        footer.textLabel?.text = footer.textLabel?.text?.uppercased()
        footer.textLabel?.textAlignment = .right
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if let payment = payments?[indexPath.row] {
            print(payment.value)
            print(indexPath.row)
            let deletionAction = UIContextualAction(style: .destructive, title: "delete") { _, _, isActionSuccessful in
                do {
                    let localAuthenticationContext = LAContext()
                    localAuthenticationContext.localizedFallbackTitle = "Please use your Passcode"

                    var authorizationError: NSError?
                    let reason = "Authentication required to delete this payment"

                    if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authorizationError) {
                        localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, _ in
                            if success {
                                DispatchQueue.main.async {
                                    isActionSuccessful(true)
                                    self.deletePayment(at: indexPath)
                                }
                            } else {
                                isActionSuccessful(false)
                            }
                        }
                    }
                }
            }

            deletionAction.image = UIImage(systemName: "trash.fill")

            let config = UISwipeActionsConfiguration(actions: [deletionAction])
            config.performsFirstActionWithFullSwipe = false
            return config
        } else {
            return nil
        }
    }

    func deletePayment(at indexPath: IndexPath) {
        if let payment = payments?[indexPath.row] {
            do {
                try realm.write {
                    self.realm.delete(payment)
                }
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
            } catch {
                tableView.cellForRow(at: indexPath)?.shake()
                print("error deleting amount at row: \(indexPath.row), error: \(error)")
            }
            tableView.reloadData()
        }
    }
}
