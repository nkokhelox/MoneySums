//
//  UserDefaults+util.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2022/03/13.
//

import Foundation

extension UserDefaults {
  static let APP_ICON_KEY = "AppIcon"
  static let PAID_AMOUNT_RETENTION_OPTION = "PaidAmountsRetention"
  
  func getPaidAmountRetentionMonths() -> Int {
    return integer(forKey: UserDefaults.PAID_AMOUNT_RETENTION_OPTION)
  }
  
  func getCurrentAppIcon() -> Int {
    return integer(forKey: UserDefaults.APP_ICON_KEY)
  }
  
  func setPaidAmountRetention(option: Int) {
    set(option, forKey: UserDefaults.PAID_AMOUNT_RETENTION_OPTION)
  }
  
  func setCurrentAppIcon(option: Int) {
    set(option, forKey: UserDefaults.APP_ICON_KEY)
  }
}
