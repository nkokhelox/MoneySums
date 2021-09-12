//
//  ViewController.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2021/08/08.
//

import UIKit
import RealmSwift

class AmountTableViewController: UITableViewController {
  let realm = try! Realm()
  
  var paidAmounts: Results<Amount>?
  var unpaidAmounts: Results<Amount>?
  
  var selectedAmountIndexPath: IndexPath? = nil
  var noteTextField: UITextField? = nil
  var amountTextField: UITextField? = nil
  var paymentTextField: UITextField? = nil
  
  var selectedPerson: Person? {
    didSet {
      self.title = selectedPerson?.name.truncate(maxLength: 15, withEllipsis: true).capitalized
      self.loadAmounts()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.separatorInset = UIEdgeInsets.zero
  }
  
  @IBAction func addAmount(_ sender: UIBarButtonItem) {
    let alert = UIAlertController(
      title: "Add Money Record",
      message: "Negative amount if you owe them.",
      preferredStyle: .alert
    )
    
    alert.addTextField(configurationHandler: self.amountTextField)
    alert.addTextField(configurationHandler: self.noteTextField)
    
    alert.addAction(UIAlertAction(title: "Save", style: .default, handler: self.saveAmount))
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    
    self.present(alert, animated: true)
  }
  
  func loadAmounts() {
    self.paidAmounts = selectedPerson?.amounts.sorted(byKeyPath: "value", ascending: false).filter("paid == %@", true)
    self.unpaidAmounts = selectedPerson?.amounts.sorted(byKeyPath: "value", ascending: false).filter("paid == %@", false)
    tableView.reloadData()
  }
}

// MARK: Add amount alert methods
extension AmountTableViewController {
  func amountTextField(textField: UITextField){
    amountTextField = textField
    textField.keyboardType = .decimalPad
    textField.returnKeyType = .next
    textField.placeholder = (0.0).moneyFormattedString()
    textField.addNumericAccessory(addPlusMinus: true)
  }
  
  func noteTextField(textField: UITextField){
    noteTextField = textField
    textField.placeholder = "add some note about this amount"
    textField.autocapitalizationType = .sentences
    textField.autocorrectionType = .default
    textField.textContentType = .givenName
  }
  
  func saveAmount(action: UIAlertAction){
    let amount = Amount(
      value: amountTextField!.text!.trimmingCharacters(in: .whitespaces).toDoubleOption()!,
      note: noteTextField!.text!.trimmingCharacters(in: .whitespaces),
      paid: false
    )
    
    if let person = selectedPerson {
      do {
        try realm.write{
          person.amounts.append(amount)
        }
      } catch {
        self.showToast(title: "⚠ ERROR", message: "saving amount for \(person.name) failed")
        print("error saving the amount for \(person.name): \(error)")
      }
    }
    
    self.tableView.reloadData()
  }
}

// MARK: Add interest alert methods
extension AmountTableViewController {
  func addPayment() {
    if let indexPath = selectedAmountIndexPath {
      var amount: Amount {
        (indexPath.section == 0 ? unpaidAmounts : paidAmounts)![indexPath.row]
      }
      
      let alert = UIAlertController(
        title: "add payment for \(amount.moneyValue)",
        message: amount.note,
        preferredStyle: .alert
      )
      
      alert.addTextField(configurationHandler: self.paymentTextField)
      
      alert.addAction(UIAlertAction(title: "save", style: .default, handler: self.savePayment))
      alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
      
      self.present(alert, animated: true)
    }
  }
  
  func paymentTextField(textField: UITextField){
    paymentTextField = textField
    textField.keyboardType = .decimalPad
    textField.returnKeyType = .done
    textField.placeholder = (0.0).moneyFormattedString()
    textField.addNumericAccessory(addPlusMinus: true)
  }
  
  func savePayment(action: UIAlertAction){
    if let indexPath = selectedAmountIndexPath {
      let interest = Payment(value: paymentTextField!.text!.toDoubleOption()!)
      
      do {
        try realm.write{
          (indexPath.section == 0 ? unpaidAmounts : paidAmounts)![indexPath.row].payments.append(interest)
        }
      } catch {
        self.showToast(title: "⚠ ERROR", message: "saving amount for \(selectedPerson!.name) failed")
        print("error saving the amount for \(selectedPerson!.name): \(error)")
      }
      
      self.tableView.reloadData()
    }
  }
}

// MARK: TableView DataSource methods
extension AmountTableViewController {
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return (section == 0 ? unpaidAmounts : paidAmounts)?.count ?? 0
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let row = tableView.dequeueReusableCell(withIdentifier: "amountRow", for: indexPath)
    let amount = (indexPath.section == 0 ? unpaidAmounts : paidAmounts)?[indexPath.row]

    row.accessoryType = amount?.paid == true ? .checkmark : .detailButton
    row.textLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
    row.detailTextLabel?.text = amount?.detailText
    row.textLabel?.text = amount?.moneyValue
    
    return row
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.rowSelected(tableView, indexPath)
  }
  
  override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
    self.rowSelected(tableView, indexPath)
  }
  
  private func  rowSelected(_ tableView: UITableView, _ indexPath: IndexPath) {
    let amounts = (indexPath.section == 0 ? unpaidAmounts : paidAmounts)
    if amounts?[indexPath.row].payments.count == 0 {
      tableView.cellForRow(at: indexPath)?.shake()
    } else {
      self.performSegue(withIdentifier: "showPayments", sender: self)
    }
    tableView.deselectRow(at: indexPath, animated: true)
    
  }
}

// MARK: Tableview row swipe action methods
extension AmountTableViewController {
  override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let amount = (indexPath.section == 0 ? unpaidAmounts : paidAmounts)![indexPath.row]
    let actionTitle = amount.paid ? "unpaid" : "paid"
    let paidToggleAction = UIContextualAction(style: .normal, title: actionTitle) { _, _, isActionSuccessful in
        isActionSuccessful(true)
        do {
          try self.realm.write {
            amount.paid = !amount.paid
          }
        } catch {
          self.showToast(title: "⚠ ERROR", message: "toggling the paid status for \(amount.moneyValue) failed")
          print("error toggling the paid status for \(amount.moneyValue)")
        }
        
        tableView.reloadData()
      }
      
      paidToggleAction.image = UIImage(systemName: amount.paid ? "xmark" : "checkmark")
      paidToggleAction.backgroundColor = UIColor(named: amount.paid ? "adaOrange" : "adaTeal")
      
      let config = UISwipeActionsConfiguration(actions: [paidToggleAction])
      config.performsFirstActionWithFullSwipe = false
    
      return config
  }
  
  override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let amount = (indexPath.section == 0 ? unpaidAmounts : paidAmounts)![indexPath.row]
    
    if amount.paid {
      let deletionAction = UIContextualAction(style: .destructive, title: "delete") { _, _, isActionSuccessful in
          isActionSuccessful(true)
          do {
            try self.realm.write{
              self.realm.delete(amount.payments)
              self.realm.delete(amount)
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            tableView.reloadData()
          } catch {
            tableView.cellForRow(at: indexPath)?.shake()
            self.showToast(title: "⚠ ERROR", message: "failed to delete \(amount.moneyValue)")
            print("error deleting amount at row: \(indexPath.row), error: \(error)")
          }
      }
      
      deletionAction.image = UIImage(systemName: "trash.fill")
      
      let config = UISwipeActionsConfiguration(actions: [deletionAction])
      config.performsFirstActionWithFullSwipe = false
      
      return config
    } else {
      let addInterestAction = UIContextualAction(style: .normal, title: "interest") {_, _, isActionSuccessful in
        self.selectedAmountIndexPath = indexPath
        isActionSuccessful(true)
        self.addPayment()
      }
      
      addInterestAction.image = UIImage(systemName: "calendar.badge.plus")
      addInterestAction.backgroundColor = UIColor(named: "adaTeal")
      
      let config = UISwipeActionsConfiguration(actions: [addInterestAction])
      config.performsFirstActionWithFullSwipe = false
      
      return config
    }
  }
}

// MARK: - Headers and Footers
extension AmountTableViewController {
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return section == 0 ? "unpaid (\(unpaidAmounts?.count ?? 0))" : "paid (\(paidAmounts?.count ?? 0))"
  }
  
  override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    let totalMoney = (section == 0 ? selectedPerson?.totalUnpaid : selectedPerson?.totalPaid) ?? 0.0
    return "total \(totalMoney.moneyFormattedString())"
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
}

// MARK: - Navigation
extension AmountTableViewController {
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let indexPath = tableView.indexPathForSelectedRow {
      let destinationViewController = segue.destination as! PaymentTableViewController
      let amounts = (indexPath.section == 0 ? unpaidAmounts : paidAmounts)
      
      destinationViewController.selectedAmount = amounts![indexPath.row]
      destinationViewController.onDismiss = {[weak self] in self?.tableView.reloadData()}
      tableView.deselectRow(at: indexPath, animated: true)
    }
  }
}

// MARK: SearchBar delegate methods
extension AmountTableViewController : UISearchBarDelegate {
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if(searchText.isEmpty) {
      loadAmounts()
      DispatchQueue.main.async {
        searchBar.resignFirstResponder()
      }
    }
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    if let searchText = searchBar.text {
      if(searchText.isEmpty) {
        self.loadAmounts()
      } else {
        paidAmounts = paidAmounts?.filter("note CONTAINS[cd] %@", searchText).sorted(byKeyPath: "value", ascending: false)
        unpaidAmounts = unpaidAmounts?.filter("note CONTAINS[cd] %@", searchText).sorted(byKeyPath: "value", ascending: false)
        tableView.reloadData()
      }
    }
  }
}

