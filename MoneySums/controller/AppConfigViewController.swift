//
//  AppConfigViewController.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2022/03/13.
//

import UIKit

class AppConfigViewController: UIViewController {
  var appLockDelegate: AppLockDelegate?
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

  func setAppIconChoice(_ choice: Int) {
    UserDefaults.standard.set(choice, forKey: UserDefaults.APP_ICON_KEY)
      refreshAppIcon()
  }

  func refreshAppIcon() {
      if #available(iOS 13, *) {
        switch UserDefaults.standard.integer(forKey:UserDefaults.APP_ICON_KEY) {
          case 0: self.clearAltIcon(); break
          default: self.setLightIcon(); break
          }
      }
  }

  func setLightIcon() {
      if UIApplication.shared.alternateIconName != "lightMode" {
          UIApplication.shared.setAlternateIconName("lightMode") { error in
              if let clearError = error {
                  print("Failed to set the alternative app icon name: \(clearError)")
              }
          }
      }
  }

  func clearAltIcon() {
      if UIApplication.shared.alternateIconName != nil {
          UIApplication.shared.setAlternateIconName(nil) { error in
              if let clearError = error {
                  print("Failed to clear the alternative app icon name: \(clearError)")
              }
          }
      }
  }
}
