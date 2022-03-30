//
//  UserDefaults+util.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2022/03/13.
//

import Foundation

extension UserDefaults {
  static let APP_ICON_KEY = "AppIcon"
  static let PAID_AMOUNT_RETENTION_MONTHS_KEY = "PaidAmountsRetention"
  
  func getPaidAmountRetentionMonths() -> Int {
    return integer(forKey: UserDefaults.PAID_AMOUNT_RETENTION_MONTHS_KEY)
  }
  
  func getCurrentAppIcon() -> Int {
    return integer(forKey: UserDefaults.APP_ICON_KEY)
  }
  
  func setPaidAmountRetention(months: Int) {
    set(months, forKey: UserDefaults.PAID_AMOUNT_RETENTION_MONTHS_KEY)
  }
  
  func setCurrentAppIcon(choiceNumber: Int) {
    set(choiceNumber, forKey: UserDefaults.APP_ICON_KEY)
  }
}
