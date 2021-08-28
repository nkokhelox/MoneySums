//
//  ViewController.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2021/08/08.
//

import UIKit

class AmountViewController: UITableViewController {
  
  var amounts: [Amount] = Amount.randomData()
  var amountTextField: UITextField? = nil
  var noteTextField: UITextField? = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
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
    
    alert.tagTextFields()
    self.present(alert, animated: true)
  }
  // MARK: Alert methods
  
  func amountTextField(textField: UITextField){
    amountTextField = textField
    textField.keyboardType = .decimalPad
    textField.returnKeyType = .next
    textField.placeholder = Amount.moneyFormat(0.0)
    textField.addNumericAccessory(addPlusMinus: true)
    textField.addNumberEntryControl()
  }
  
  func noteTextField(textField: UITextField){
    noteTextField = textField
    textField.placeholder = "add some note about this amount"
    textField.autocapitalizationType = .sentences
  }
  
  func saveAmount(action: UIAlertAction){
    self.amounts.append(
      Amount(
        value: Amount.doubleFromString(amountTextField!.text!)!,
        note: noteTextField!.text!,
        paid: false
      )
    )
    
    self.tableView.reloadData()
    
  }
  
  // MARK: TableView DataSource methods
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return amounts.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let row = tableView.dequeueReusableCell(withIdentifier: "amountRow", for: indexPath)
    
    row.textLabel?.text = amounts[indexPath.row].moneyValue
    row.detailTextLabel?.text = amounts[indexPath.row].note
    
    row.accessoryType = amounts[indexPath.row].paid ? .checkmark: .none
    row.backgroundColor = (indexPath.row%2 == 0) ? row.backgroundColor : tableView.separatorColor
    return row
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // show more details slide up modal.
    let amount = amounts[indexPath.row]
    amounts[indexPath.row] = Amount(value: amount.value, note: amount.note, paid: !amount.paid)
    tableView.deselectRow(at: indexPath, animated: true)
    tableView.reloadData()
  }
  
}

