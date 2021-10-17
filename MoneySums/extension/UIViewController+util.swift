//
//  UIAlertViewController+util.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2021/09/10.
//

import UIKit
import Toast

extension UIViewController{
 func showToast(message:String) {
   self.view.makeToast(message, duration: 5.0, position: CSToastPositionBottom)
  }
}
