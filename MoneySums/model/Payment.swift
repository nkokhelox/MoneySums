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
    @objc dynamic var note: String = ""
    var moneyValue: String {
        return value.moneyFormattedString()
    }

    var amount = LinkingObjects(fromType: Amount.self, property: "payments")

    convenience init(value: Double, note: String) {
        self.init()
        self.value = value
        self.note = note
    }

  func niceDescription(_ separator: String = " ") -> String {
        let paymentDate = paidDate.niceDescription()
        return note.isEmpty ? paymentDate : "\(paymentDate)\(separator)\(note)"
    }
}
