//
//  UserDefaults+util.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2022/03/13.
//

import Foundation

extension UserDefaults {
    static let APP_LOCKED_MANUALLY = "AppLockedManually"
    static let APP_ICON_KEY = "AppIcon"
    static let APP_ENTERED_BACKGROUND_TIME = "AppBgMoment"
    static let PAID_AMOUNT_RETENTION_OPTION = "PaidAmountsRetention"

    func getPaidAmountRetentionMonths() -> Int {
        switch paidAmountRetentionOption() {
        case 1: return 12
        case 2: return 6
        case 3: return 3
        default: return 0
        }
    }

    func paidAmountRetentionOption() -> Int {
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

    func enteredBackgroundNow() {
        set(Date(), forKey: UserDefaults.APP_ENTERED_BACKGROUND_TIME)
    }

    func unlockApp() {
        removeObject(forKey: UserDefaults.APP_ENTERED_BACKGROUND_TIME)
        set(false, forKey: UserDefaults.APP_LOCKED_MANUALLY)
    }

    func appIsManuallyLocked() {
        set(true, forKey: UserDefaults.APP_LOCKED_MANUALLY)
    }

    func remainLocked() -> Bool {
        let isLockedManually = bool(forKey: UserDefaults.APP_LOCKED_MANUALLY)
        if isLockedManually {
            return true
        }

        if let interval = (object(forKey: UserDefaults.APP_ENTERED_BACKGROUND_TIME) as? Date)?.timeIntervalSinceNow {
            return abs(interval) > 5 // 30 minutes
        }

        return false
    }
}
