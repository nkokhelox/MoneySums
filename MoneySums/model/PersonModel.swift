//
//  PersonModel.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2021/09/07.
//

import Foundation
import RealmSwift

class PersonModel: Object {
  @objc dynamic var name: String = ""
  let amounts = List<AmountModel>()
  var total: Double {
    totalPaid + totalUnpaid
  }
  
  var totalPaid: Double {
    amounts.reduce(0.0) { sum, amount in
      sum + (amount.paid ? amount.value : 0.0)
    }
  }
  
  var totalUnpaid: Double {
    amounts.reduce(0.0) { sum, amount in
      sum + (amount.paid ? 0.0 : amount.value)
    }
  }
  
  convenience init(name: String) {
    self.init()
    self.name = name
  }
  
}

