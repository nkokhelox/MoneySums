//
//  AmountModel.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2021/08/27.
//

import Foundation

struct Amount {
  let value:Double
  let note: String
  let paid: Bool
  var moneyValue: String {
    return Amount.moneyFormat(value)
  }
  
  static func doubleFromString(_ value: String)->Double? {
    let formatter = NumberFormatter()
    return formatter.number(from: value)?.doubleValue
  }
  
  static func moneyFormat(_ value: Double)->String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    return formatter.string(from: value as NSNumber) ?? value.description
  }
  
  static func randomData() -> [Amount] {
    return Array(0...10).map {
      Amount(
        value: Double($0),
        note: ($0 % 2 == 0) ? "even even even even even even even even even even even even even even even even even even even even even even even even even even even even even even even even even even even even even even even even even even even even even even even even even even even even even even even even even even even even even even even even even even" : "odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd odd",
        paid: [true, false].shuffled().first ?? true
      )
    }
  }
}

