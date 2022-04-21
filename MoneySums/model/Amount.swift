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
    @objc dynamic var datePaid: Date?
    @objc dynamic var dateCreated: Date = Date()

    let payments = List<Payment>()

    var isPaid: Bool {
        return datePaid != nil
    }

    var moneyValue: String {
        return value.moneyFormattedString()
    }

    var paymentsTotal: Double {
        payments.sum(ofProperty: "value")
    }

    var latestPaymentDate: Date? {
        latestPayment?.paidDate
    }

    var latestPayment: Payment? {
        payments.sorted(byKeyPath: "dateCreated", ascending: true).first
    }

    var detailText: String {
        let detail = note.isEmpty ? paymentsDetailText : note
        let date = (datePaid ?? dateCreated).niceDescription()
      return String(format: "%@ by %@ - %@", (isPaid ? "paid": "created"), date, detail)
    }

    var paymentsDetailText: String {
        let diff = paymentsDifference
        return String(format: diff <= 0 ? "%@" : "%@ (iou)", abs(diff).moneyFormattedString())
    }

    var fullDetailText: String {
        return
            """
                Created \(dateCreated.niceDescription())
                \(isPaid ? "Fully paid \(datePaid!.niceDescription())" : "NOT fully paid")
                Note: \(note.isEmpty ? "N/A" : note)
            """
    }

    var paymentsDifference: Double {
        paymentsTotal - value
    }

    var person = LinkingObjects(fromType: Person.self, property: "amounts")

    convenience init(value: Double, note: String) {
        self.init()
        self.value = value
        self.note = note
    }

    func wasPaidMoreThan(monthsAgo: Int) -> Bool {
        return (datePaid?.monthsFromNow() ?? 0) > monthsAgo
    }
}
