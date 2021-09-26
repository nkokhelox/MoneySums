//
//  PaymentTableViewController.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2021/09/11.
//

import UIKit
import RealmSwift

class PaymentTableViewController: UITableViewController {
  let realm = try! Realm(configuration: Realm.Configuration(schemaVersion: 2))
 
  var onDismiss: (() -> Void)? = nil
  
  @IBOutlet weak var footNote: UILabel!
  @IBOutlet weak var dragPill: UIImageView!
  
  var payments: Results<Payment>?
  
  var selectedAmount: Amount? {
    didSet{
      loadPayments()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    footNote.text = selectedAmount?.paymentsDetailText.uppercased()
    footNote.alpha = (selectedAmount?.paymentsDifference ?? 0) == 0 ? 0.3 : 0.5
    footNote.textColor = (selectedAmount?.paymentsDifference ?? 0) == 0 ? UIColor.adaAccentColor : (selectedAmount?.paymentsTotal ?? 0 > 0) ? UIColor.adaOrange : UIColor.adaTeal
    
    tableView.separatorInset = UIEdgeInsets.zero
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    onDismiss?()
  }
  
  func loadPayments() {
    self.payments = selectedAmount?.payments.sorted(byKeyPath: "paidDate", ascending: false)
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
    if let interest = payments?[indexPath.row] {
      let deletionAction = UIContextualAction(style: .destructive, title: "delete") { _, _, isActionSuccessful in
        isActionSuccessful(true)
        do {
          try self.realm.write{
            self.realm.delete(interest)
          }
          tableView.deleteRows(at: [indexPath], with: .automatic)
          tableView.endUpdates()
        } catch {
          tableView.cellForRow(at: indexPath)?.shake()
          self.showToast(title: "⚠ ERROR", message: "⚠ failed to delete \(interest.moneyValue)")
          print("error deleting amount at row: \(indexPath.row), error: \(error)")
        }
        tableView.reloadData()
      }
      
      deletionAction.image = UIImage(systemName: "trash.fill")
      
      let config = UISwipeActionsConfiguration(actions: [deletionAction])
      config.performsFirstActionWithFullSwipe = false
      return config
    } else {
      return nil
    }
  }
  
}
