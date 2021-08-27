//
//  UITextField+util.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2021/08/27.
//

import UIKit
extension UITextField {
  
  func addNumericAccessory(addPlusMinus: Bool, add00Entry: Bool = false) {
    let numberToolbar = UIToolbar()
    numberToolbar.barStyle = UIBarStyle.default
    
    var accessories : [UIBarButtonItem] = []
    
    accessories.append(UIBarButtonItem(title: "Clear", style: UIBarButtonItem.Style.plain, target: self, action: #selector(numberPadClear)))
    
    if addPlusMinus {
      accessories.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
      accessories.append(UIBarButtonItem(title: "+/-", style: UIBarButtonItem.Style.plain, target: self, action: #selector(plusMinusPressed)))
    }
    
    if add00Entry {
      accessories.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
      accessories.append(UIBarButtonItem(title: "00", style: UIBarButtonItem.Style.plain, target: self, action: #selector(append00)))
    }
    
    accessories.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
    var returnTypeAccessoryTitle = "Done"
    switch self.returnKeyType {
    case .next:
      returnTypeAccessoryTitle = "Next"
    default:
      returnTypeAccessoryTitle = "Done"
    }
    
    accessories.append(UIBarButtonItem(title: returnTypeAccessoryTitle, style: UIBarButtonItem.Style.done, target: self, action: #selector(numberEntryDone)))

    
    numberToolbar.items = accessories
    numberToolbar.sizeToFit()
    
    inputAccessoryView = numberToolbar
  }
  
  func addNumberEntryControl() {
// validate the provided amount
  }
  
  // MARK: Private functions
  @objc private func numberEntryDone() {
    self.resignFirstResponder()
    let t = (self.next as? UITextField)
    self.next?.becomeFirstResponder()
  }
  
  @objc private func append00() {
    self.text = self.text?.appending("00")
  }
  
  @objc private func numberPadClear() {
    self.text = ""
  }
  
  @objc private func plusMinusPressed() {
    if let currentText = self.text {
      self.text = currentText.hasPrefix("-") ? String(currentText.dropFirst()) : "-" + currentText
    }
  }
  
}
