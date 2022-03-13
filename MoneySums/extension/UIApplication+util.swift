//
//  UIApplication+util.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2022/03/13.
//

import Foundation
import UIKit
import RealmSwift


extension UIApplication {
  static let SCHEMA_VERSION: UInt64 = 3
  
  static func getRealm() -> Realm {
    return try! Realm(configuration: Realm.Configuration(schemaVersion: SCHEMA_VERSION))
  }
                      
  static func initRealm() throws {
    try Realm(
      configuration: Realm.Configuration(
        schemaVersion: SCHEMA_VERSION,
        migrationBlock: { migration, _ in
            migration.enumerateObjects(ofType: "Amount") { oldObject, newObject in
              guard let isPaid = oldObject?["paid"] as? Bool else { return }
                if isPaid {
                    newObject?["datePaid"] = Date()
                }
            }
        }
      )
    )
  }
}
