//
//  Amount.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2021/08/27.
//

import Foundation
import RealmSwift

class Amount: Object {
  @objc dynamic var value: Double = 0.0
  @objc dynamic var note: String = ""
  @objc dynamic var paid: Bool = false
  let payments = List<Payment>()
  var moneyValue: String {
    return value.moneyFormattedString()
  }
  var paymentsTotal: Double {
    payments.sum(ofProperty: "value")
  }
  
  var detailText: String {
    note.isEmpty ? paymentsDetailText : note
  }
  
  var paymentsDetailText: String {
    let diff = paymentsTotal - value
    return (diff < 0 ? "deficit: \((-diff).moneyFormattedString())" : "profit: \(diff.moneyFormattedString())").uppercased()
  }
  
  var person = LinkingObjects(fromType: Person.self, property: "amounts")
  
  convenience init(value: Double, note: String, paid: Bool) {
    self.init()
    self.value = value
    self.note = note
    self.paid = paid
  }
}
