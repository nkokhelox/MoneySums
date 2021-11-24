//
//  UIAlertViewController+util.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2021/09/10.
//

import Toast
import UIKit

extension UIViewController {
    func showToast(message: String) {
        view.makeToast(message, duration: 5.0, position: CSToastPositionBottom)
    }
}
