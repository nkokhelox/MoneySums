//
//  AmountModel.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2021/08/27.
//

import Foundation

struct Amount {
  let value:Int64
  let note: String
  let paid: Bool
  
  static func randomData() -> [Amount] {
    return Array(0...10).map {
      Amount(
        value: $0,
        note: ($0 % 2 == 0) ? "even" : "odd",
        paid: [true, false].shuffled().first ?? true
      )
    }
  }
}

