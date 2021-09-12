//
//  UIAlertViewController+util.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2021/09/10.
//

import UIKit

extension UIViewController{
  func showToast(title:String?, message:String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
    
    if let popoverController = alert.popoverPresentationController {
      popoverController.sourceView = self.view
      popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.height, width: 0, height: 0)
    }
    
    self.present(alert, animated: true)
    let seconds = 2.0
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
      alert.dismiss(animated: true)
    }
  }
}
