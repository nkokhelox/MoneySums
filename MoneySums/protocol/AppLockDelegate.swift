//
//  LockAppDelegate.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2022/03/13.
//

import Foundation

protocol AppLockDelegate {
    func willEnterForeground()

    func lockApp(authorizeNow: Bool, isManuallyLocked: Bool)
}
