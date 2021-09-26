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
  @objc dynamic var dateCreated: Date = Date()
  
  let payments = List<Payment>()
  
  var moneyValue: String {
    return value.moneyFormattedString()
  }
  
  var paymentsTotal: Double {
    payments.sum(ofProperty: "value")
  }
  
  var detailText: String {
    let detail = note.isEmpty ? paymentsDetailText : note
    let dateCreated = dateCreated.niceDescription()
    return String(format: "%@ - %@", dateCreated, detail)
  }
  
  var paymentsDetailText: String {
    let diff = paymentsDifference
    return String(format: diff < 0 ? "deficit: %@" : diff > 0 ? "profit: %@" : "squince", abs(diff).moneyFormattedString()).capitalized
  }
  
  var paymentsDifference: Double {
     paymentsTotal - value
  }
  
  var person = LinkingObjects(fromType: Person.self, property: "amounts")
  
  convenience init(value: Double, note: String, paid: Bool) {
    self.init()
    self.value = value
    self.note = note
    self.paid = paid
  }
}
