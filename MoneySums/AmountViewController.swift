//
//  ViewController.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2021/08/08.
//

import UIKit

class AmountViewController: UITableViewController {
  
  var amounts: [Amount] = Amount.randomData()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }
  @IBAction func addAmount(_ sender: UIBarButtonItem) {
    
    navigationController?.navigationBar.shake()
    
    let alert = UIAlertController(
      title: "Add Money Record",
      message: "Negative amount if you owe them.",
      preferredStyle: .alert
    )
    
    let saveAction = UIAlertAction(
      title: "Save",
      style: .default,
      handler: { action in
        print("save pressed")
        guard let amount = Int64((alert.textFields?.first?.text!)!) else {
          return
        }
        
        self.amounts.append(
          Amount(
            value: amount,
            note: alert.textFields?.last?.text ?? "unspecified",
            paid: false
        )
        )
        
        self.tableView.reloadData()
        
      })
    
    //    saveAction.isEnabled = false
    
    alert.addTextField(configurationHandler: { amountField in
      amountField.keyboardType = .decimalPad
      amountField.returnKeyType = .next
      amountField.placeholder = "0.00"
      amountField.addNumericAccessory(addPlusMinus: true)
      amountField.addNumberEntryControl()
    })
    
    alert.addTextField(configurationHandler: { noteField in
      noteField.placeholder = "add some note about this amount"
      noteField.autocapitalizationType = .sentences
    })
    
    alert.addAction(saveAction)
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
      print("cancel pressed")
    }))
    
    alert.tagTextFields()
    self.present(alert, animated: true)
  }
  
  // MARK: TableView DataSource methods
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return amounts.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let row = tableView.dequeueReusableCell(withIdentifier: "amountRow", for: indexPath)
    row.textLabel?.text = amounts[indexPath.row].value.description
    row.detailTextLabel?.text = amounts[indexPath.row].note
    
    row.accessoryType = amounts[indexPath.row].paid ? .checkmark: .none
    row.backgroundColor = (indexPath.row%2 == 0) ? row.backgroundColor : tableView.separatorColor
    return row
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // show more details slide up modal.
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
}

