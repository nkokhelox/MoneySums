//
//  UIAlertController.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2022/01/28.
//

import Foundation
import UIKit

extension UIAlertController {
    enum ValidationIdFlag {
        static let nonEmpty = "_noempty_"
        static let isNumber = "_numeric_"
    }

    @objc func noDefaultActionOnEmptyFieldValidation(_ sender: UITextField) {
        if let fieldsToCheck = (textFields?.filter { $0.accessibilityIdentifier?.contains(ValidationIdFlag.nonEmpty) == true }) {
            actions.filter { $0.style == .default }.forEach { $0.isEnabled = fieldsToCheck.isEmpty || fieldsToCheck.allSatisfy { $0.text?.isEmpty == false }}
        }
    }

    @objc func isNumberFieldValidation(_ sender: UITextField) {
        if let fieldsToCheck = (textFields?.filter { $0.accessibilityIdentifier?.contains(ValidationIdFlag.isNumber) == true }) {
            actions.filter {
                $0.style == .default
            }.forEach {
                $0.isEnabled = fieldsToCheck.isEmpty || fieldsToCheck.allSatisfy { $0.text?.toDoubleOption() != nil && $0.text?.toDoubleOption() != 0.0 }
            }
        }
    }

    func applyIsNumberValidation() {
        if let fieldsToCheck = (textFields?.filter { $0.accessibilityIdentifier?.contains(ValidationIdFlag.isNumber) == true }) {
            actions.filter {
                $0.style == .default
            }.forEach {
                $0.isEnabled = false
            }

            fieldsToCheck.forEach {
                $0.addTarget(self, action: #selector(self.isNumberFieldValidation(_:)), for: .editingChanged)
            }
        }
    }

    func applyNoEmptyValidation() {
        if let fieldsToCheck = (textFields?.filter { $0.accessibilityIdentifier?.contains(ValidationIdFlag.nonEmpty) == true }) {
            actions.filter {
                $0.style == .default
            }.forEach {
                $0.isEnabled = false
            }

            fieldsToCheck.forEach {
                $0.addTarget(self, action: #selector(self.noDefaultActionOnEmptyFieldValidation(_:)), for: .editingChanged)
            }
        }
    }
}
