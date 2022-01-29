//
//  Person.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2021/09/07.
//

import Foundation
import RealmSwift

class Person: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var dateCreated: Date = Date()
    let amounts = List<Amount>()

    var firstName: String {
        String(name.split(separator: " ").first!)
    }

    var totalPaid: Double {
        amounts.reduce(0.0) { sum, amount in
            sum + (amount.paid ? amount.value : 0.0)
        }
    }

    var totalUnpaid: Double {
        amounts.reduce(0.0) { sum, amount in
          sum + (amount.paid ? 0.0 : amount.paymentsDifference)
        }
    }

    convenience init(name: String) {
        self.init()
        self.name = name
    }
}
