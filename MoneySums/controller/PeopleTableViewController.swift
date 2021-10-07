//
//  PeopleTableViewController.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2021/09/07.
//

import UIKit
import RealmSwift
import DVPieChart

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
    
    AuthorizationOverlay.shared.showOverlay(isDarkModeEnabled: traitCollection.userInterfaceStyle == .dark)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    loadPeople()
  }
  
  func updateLoadTime() {
    lastDataLoadTime.text = "Last load @ \(Date().hms())"
    self.refreshControl?.endRefreshing()
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
  
  
  // MARK: - Chart datasource
  func customizeChart(chartView: DVPieChart) {
    if let people = people?.filter({$0.totalUnpaid != 0.0}) {
      
      let amountsSum = people.reduce(0.0) {
        $0 + abs($1.totalUnpaid)
      }
      
      var dataEntries1: [DVPieSliceModel] = []
      var dataEntries2: [DVPieSliceModel] = []
      for (index, person) in people.enumerated() {
        let m = DVPieSliceModel()
        m.name = person.firstName
        m.rate = abs(person.totalUnpaid) / amountsSum
        if index < (people.count/2) {
          dataEntries1.append(m)
        } else {
          dataEntries2.append(m)
        }
      }
      
      dataEntries1.sort { $0.rate > $1.rate}
      dataEntries2.sort { $0.rate < $1.rate}
      let dataEntries = zipMerge(dataEntries1, dataEntries2)
      
      chartView.sliceNameColor = UIColor.adaAccentColor
      chartView.pieCenterCirclePercentage = 1.2
      chartView.dataArray = dataEntries
      chartView.clipsToBounds = true
      chartView.sizeToFit()
      chartView.title = "μ°"
      chartView.draw()
      
    }
  }
  
  private func zipMerge(_ array1: Array<DVPieSliceModel>, _ array2: Array<DVPieSliceModel>) -> Array<DVPieSliceModel> {
    if array1.count == array2.count {
      return Array(zip(array1, array2).flatMap({[$0, $1]}))
    }
    
    if array1.count > array2.count {
      var joined = Array(zip(array1[0...array2.count], array2).flatMap({[$0, $1]}))
      joined.append(contentsOf: array1[array2.count..<array1.count])
      return joined
    }
    
    var joined = zip(array2[0...array1.count], array1).flatMap({[$0, $1]})
    joined.append(contentsOf: array2[array1.count..<array2.count])
    return joined
  }
  
  
  // MARK: - App info
  func showAppInfo() {
    let alert = UIAlertController(
      title: "\(Bundle.main.appName)",
      message: "Version \(Bundle.main.appVersion) (\(Bundle.main.appBuild))\nUsed frameworks\n\u{2022}DVPieChart",
      preferredStyle: .alert
    )
    
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    
    self.present(alert, animated: true)
  }
  
  
}
