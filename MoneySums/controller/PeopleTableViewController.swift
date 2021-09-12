//
//  PeopleTableViewController.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2021/09/07.
//

import UIKit
import RealmSwift

class PeopleTableViewController: UITableViewController {
  let realm = try! Realm()
  var people: Results<PersonModel>?
  var nameTextField: UITextField? = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.separatorInset = UIEdgeInsets.zero
    UITableViewHeaderFooterView.appearance().tintColor = UIColor(named: "adaTeal")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    loadPeople()
  }
  
  @IBAction func addPerson(_ sender: UIBarButtonItem) {
    let alert = UIAlertController(
      title: "Add a Person",
      message: "Person you have money relationship with.",
      preferredStyle: .alert
    )
    
    alert.addTextField(configurationHandler: self.nameTextField)
    alert.addAction(UIAlertAction(title: "Save", style: .default, handler: self.savePerson))
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    
    self.present(alert, animated: true)
  }
  
  func savePerson(_ uiAlertAction: UIAlertAction) {
    let person  = PersonModel()
    person.name = self.nameTextField!.text!
    
    do {
      try realm.write{
        realm.add(person)
      }
    } catch {
      print("Failed to save Person: \(error)")
    }
    tableView.reloadData()
  }
  
  func nameTextField(_ textField: UITextField) {
    nameTextField = textField
  }
  
  func loadPeople() {
    people = realm.objects(PersonModel.self).sorted(byKeyPath: "name", ascending: true)
    tableView.reloadData()
  }
  
  // MARK: - Table view data source
  override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    let total = people?.reduce(0.0) {
      $0 + $1.total
    }
    return "Total: \((total ?? 0.0).moneyFormattedString())"
  }

  override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
    let footer: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
    footer.textLabel?.text = footer.textLabel?.text?.uppercased()
    footer.textLabel?.textAlignment = .right
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let row = tableView.dequeueReusableCell(withIdentifier: "personRow", for: indexPath)
    
    row.accessoryType = .disclosureIndicator
    row.textLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
    row.textLabel?.text = people?[indexPath.row].name.capitalized
    row.detailTextLabel?.text = people?[indexPath.row].total.moneyFormattedString()
    return row
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return people?.count ?? 0
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if (people?.count ?? 0) > 0 {
      performSegue(withIdentifier: "showAmounts", sender: self)
    } else {
      tableView.deselectRow(at: indexPath, animated: true)
    }
  }
  
  override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let deletionAction = UIContextualAction(style: .destructive, title: "delete") { _, _, isActionSuccessful in
      if self.people?[indexPath.row].total != 0 {
        isActionSuccessful(false)
        tableView.cellForRow(at: indexPath)?.shake()
        self.showToast(title: nil, message: "Balance must be zero before deleting the person")
      } else {
        isActionSuccessful(true)
        do {
          try self.realm.write{
            self.realm.delete(self.people![indexPath.row].amounts)
            self.realm.delete(self.people![indexPath.row])
          }
          tableView.deleteRows(at: [indexPath], with: .automatic)
          tableView.endUpdates()
          tableView.reloadData()
        } catch {
          self.showToast(title: "⚠ ERROR", message: "⚠ Failed to delete \(self.people?[indexPath.row].name)")
          print("Error deleting person at row: \(indexPath.row), error: \(error)")
        }
      }
      
    }
    
    deletionAction.image = UIImage(systemName: "trash")
    let config = UISwipeActionsConfiguration(actions: [deletionAction])
    
    config.performsFirstActionWithFullSwipe = people?[indexPath.row].total == 0
    return config
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
        tableView.reloadData()
      }
    }
  }
}

