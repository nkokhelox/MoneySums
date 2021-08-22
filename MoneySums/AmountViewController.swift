//
//  ViewController.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2021/08/08.
//

import UIKit

class AmountViewController: UITableViewController {
  
  var amounts: [Int] = Array(1...10)

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }
  @IBAction func addAmount(_ sender: UIBarButtonItem) {
    amounts.append(8)
    print("add amount")
    tableView.reloadData()
  }
  
  // MARK: TableView DataSource methods
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return amounts.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let row = tableView.dequeueReusableCell(withIdentifier: "categoryRow", for: indexPath)
    row.textLabel?.text = amounts[indexPath.row].description
    return row
  }
  
}

