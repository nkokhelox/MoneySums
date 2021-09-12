//
//  String+util.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2021/09/07.
//

import Foundation

extension String {
  
  func toDoubleOption() -> Double? {
    let formatter = NumberFormatter()
    return formatter.number(from: self)?.doubleValue
  }
  
  func truncate(maxLength: Int, withEllipsis: Bool) -> String {
    if(self.count > maxLength) {
      if(withEllipsis) {
        return String(self[self.startIndex..<self.index(self.startIndex, offsetBy:(maxLength-1))].appending("\u{2026}"))
      } else {
        return String(self[self.startIndex..<self.index(self.startIndex, offsetBy:maxLength)])
      }
    }
    return self
  }
}
