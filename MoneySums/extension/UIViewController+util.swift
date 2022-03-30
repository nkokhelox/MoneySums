//
//  UIViewController+util.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2022/03/14.
//

import Foundation
import UIKit
extension UIViewController {
  
  func hideKeyboardWhenTappedAround() {
      let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
      tap.cancelsTouchesInView = false
      view.addGestureRecognizer(tap)
  }
  
  @objc func dismissKeyboard() {
      view.endEditing(true)
  }
}
