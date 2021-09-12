//
//  Double+util.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2021/09/07.
//

import Foundation

extension Double {
  func moneyFormattedString() -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    return formatter.string(from: self as NSNumber) ?? self.description
  }
}
