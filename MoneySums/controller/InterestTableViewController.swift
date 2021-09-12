//
//  InterestTableTableViewController.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2021/09/11.
//

import UIKit
import RealmSwift

class InterestTableViewController: UITableViewController {
  let realm = try! Realm()
  var onDismiss: (() -> Void)? = nil
  @IBOutlet weak var dragPill: UIImageView!
  var interests: Results<InterestModel>?
  var selectedAmount: AmountModel? {
    didSet{
      loadInterests()
    }
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    view.layer.cornerRadius = 25
    dragPill.layoutMargins = UIEdgeInsets(top: 80, left: 8, bottom: 8, right: 8)
    tableView.separatorInset = UIEdgeInsets.zero
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    onDismiss?()
  }
  
  func loadInterests() {
    self.interests = selectedAmount?.interests.sorted(byKeyPath: "paidDate", ascending: true)
    tableView.reloadData()
  }
  
  // MARK: - Table view data source
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return selectedAmount?.interests.count ?? 0
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let row = tableView.dequeueReusableCell(withIdentifier: "interestRow", for: indexPath)
    row.textLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
    row.textLabel?.text = selectedAmount?.interests[indexPath.row].moneyValue
    row.detailTextLabel?.text = selectedAmount?.interests[indexPath.row].formattedPaidDate
    return row
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "Interest for \(selectedAmount!.moneyValue)"
  }
  
  override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    return "Total \(selectedAmount!.totalInterest.moneyFormattedString())"
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
    if let interest = interests?[indexPath.row] {
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
          self.showToast(title: "⚠ ERROR", message: "⚠ Failed to delete \(interest.moneyValue)")
          print("Error deleting amount at row: \(indexPath.row), error: \(error)")
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
