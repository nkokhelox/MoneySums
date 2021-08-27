//
//  UIAlertController+util.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2021/08/27.
//

import UIKit
extension UIAlertController {
  func tagTextFields() {
    if let textFields = self.textFields {
      for(index, textField) in textFields.enumerated() {
        textField.tag = index
      }
    }
  }
}
