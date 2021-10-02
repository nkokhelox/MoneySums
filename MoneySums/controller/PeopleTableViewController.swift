//
//  PeopleTableViewController.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2021/09/07.
//

import UIKit
import Charts
import RealmSwift

class PeopleTableViewController: UITableViewController {
  let realm = try! Realm(configuration: Realm.Configuration(schemaVersion: 2))
  var people: Results<Person>?
  var nameTextField: UITextField? = nil
  @IBOutlet weak var lastDataLoadTime: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.separatorInset = UIEdgeInsets.zero
    UITableViewHeaderFooterView.appearance().tintColor = UIColor.adaTeal
    
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(self.loadPeople), for: .valueChanged)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    loadPeople()
  }
  
  func updateLoadTime() {
    lastDataLoadTime.text = "Last load @ \(Date().hms())"
    self.refreshControl?.endRefreshing()
  }
  
  @IBAction func addPerson(_ sender: UIBarButtonItem) {
    let alert = UIAlertController(
      title: "add a person",
      message: "someone you have money relationship with.",
      preferredStyle: .alert
    )
    
    alert.addTextField(configurationHandler: self.nameTextField)
    alert.addAction(UIAlertAction(title: "save", style: .default, handler: self.savePerson))
    alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
    
    self.present(alert, animated: true)
  }
  
  func savePerson(_ uiAlertAction: UIAlertAction) {
    let person  = Person()
    person.name = self.nameTextField!.text!
    
    do {
      try realm.write{
        realm.add(person)
      }
    } catch {
      print("failed to save a person: \(error)")
    }
    tableView.reloadData(completion: self.updateLoadTime)
  }
  
  func nameTextField(_ textField: UITextField) {
    textField.autocapitalizationType = .words
    textField.autocorrectionType = .default
    textField.textContentType = .givenName
    nameTextField = textField
  }
  
  @objc func loadPeople() {
    people = realm.objects(Person.self).sorted(byKeyPath: "name", ascending: true)
    tableView.reloadData(completion: self.updateLoadTime)
  }
  
  // MARK: - Table view data source
  override func numberOfSections(in tableView: UITableView) -> Int {
    return people?.isEmpty ?? true ? 0 : 2
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
    return indexPath.section == 0 ? super.tableView(tableView, heightForRowAt: indexPath) : CGFloat(UIScreen.main.bounds.width)
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
      let chartView = row.contentView.subviews.first
      chartView?.bounds = row.bounds
      customizeChart(chartView: chartView as! PieChartView)
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
    if indexPath.section == 0 {
      let deletionAction = UIContextualAction(style: .destructive, title: "delete") { _, _, isActionSuccessful in
        if self.people?[indexPath.row].totalUnpaid != 0 {
          isActionSuccessful(false)
          tableView.cellForRow(at: indexPath)?.shake()
          self.showToast(title: nil, message: "balance must be zero before deleting the person")
        } else {
          isActionSuccessful(true)
          do {
            try self.realm.write{
              self.realm.delete(self.people![indexPath.row].amounts)
              self.realm.delete(self.people![indexPath.row])
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            tableView.reloadData(completion: self.updateLoadTime)
          } catch {
            self.showToast(title: "⚠ ERROR", message: "⚠ failed to delete \((self.people?[indexPath.row].name)!)")
            print("error deleting person at row: \(indexPath.row), error: \(error)")
          }
        }
        
      }
      
      deletionAction.image = UIImage(systemName: "trash")
      let config = UISwipeActionsConfiguration(actions: [deletionAction])
      
      config.performsFirstActionWithFullSwipe = people?[indexPath.row].totalUnpaid == 0
      return config
    }
    return nil
  }
  
  
  // MARK: - Chart datasource
  func customizeChart(chartView: PieChartView) {
    
    if let persons = people {
    // 1. Set ChartDataEntry
    var dataEntries: [ChartDataEntry] = []
    for person in persons {
      dataEntries.append(PieChartDataEntry(value: abs(person.totalUnpaid), label: person.firstName))
    }

    // 2. Set ChartDataSet
    let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: nil)
      pieChartDataSet.sliceSpace = 1
      pieChartDataSet.useValueColorForLine = true
    pieChartDataSet.colors = UIColor.chartColors
      pieChartDataSet.valueTextColor = UIColor.label
//      pieChartDataSet.drawValuesEnabled = false
      pieChartDataSet.yValuePosition = .insideSlice
      pieChartDataSet.xValuePosition = .outsideSlice
      pieChartDataSet.valueLinePart1Length = 0.4
      pieChartDataSet.valueLinePart2Length = 0.1
      
    // 3. Set ChartData
    let pieChartData = PieChartData(dataSet: pieChartDataSet)
    let format = NumberFormatter()
    format.numberStyle = .percent
      format.maximumFractionDigits = 1
      format.multiplier = 1.0
    let formatter = DefaultValueFormatter(formatter: format)
    pieChartData.setValueFormatter(formatter)
    
    // 4. Assign it to the chart’s data
    chartView.data = pieChartData
      chartView.usePercentValuesEnabled = true
      chartView.holeColor = UIColor.clear
//      chartView.drawEntryLabelsEnabled = false
      chartView.rotationAngle = 269.6
//      chartView.legend.enabled = false
  }
  }
  
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let destinationViewController = segue.destination as! AmountTableViewController
    if let selectedRowIndexPath = tableView.indexPathForSelectedRow{
      destinationViewController.selectedPerson = people?[selectedRowIndexPath.row]
    }
  }
}

// MARK: SearchBar delegate methods
extension PeopleTableViewController : UISearchBarDelegate {
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if(searchText.isEmpty) {
      loadPeople()
      DispatchQueue.main.async {
        searchBar.resignFirstResponder()
      }
    }
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    if let searchText = searchBar.text {
      if(searchText.isEmpty) {
        self.loadPeople()
      } else {
        people = people?.filter("name CONTAINS[cd] %@", searchText).sorted(byKeyPath: "name", ascending: true)
        tableView.reloadData(completion: self.updateLoadTime)
      }
    }
  }
}


