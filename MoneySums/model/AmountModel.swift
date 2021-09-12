//
//  AmountModel.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2021/08/27.
//

import Foundation
import RealmSwift

class AmountModel: Object {
  @objc dynamic var value: Double = 0.0
  @objc dynamic var note: String = ""
  @objc dynamic var paid: Bool = false
  let interests = List<InterestModel>()
  var moneyValue: String {
    return value.moneyFormattedString()
  }
  var totalInterest: Double {
    interests.sum(ofProperty: "value")
  }
  
  var detailText: String {
    note.isEmpty ? "Interest: \(totalInterest.moneyFormattedString())" : note
  }
  
  var person = LinkingObjects(fromType: PersonModel.self, property: "amounts")
  
  convenience init(value: Double, note: String, paid: Bool) {
    self.init()
    self.value = value
    self.note = note
    self.paid = paid
  }
}
