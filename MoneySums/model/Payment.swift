//
//  Payment.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2021/09/10.
//

import Foundation
import RealmSwift

class Payment: Object {
  @objc dynamic var value: Double = 0.0
  @objc dynamic var paidDate: Date = Date()
  var moneyValue: String {
    return value.moneyFormattedString()
  }
  var formattedPaidDate: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE, MMM d, yyyy '@' HH:mm"
    return dateFormatter.string(from: paidDate)
  }
  var amount = LinkingObjects(fromType: Amount.self, property: "payments")
  
  convenience init(value: Double) {
    self.init()
    self.value = value
  }
}
