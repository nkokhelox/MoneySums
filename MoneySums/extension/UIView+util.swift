//
//  UIViewExtension.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2021/08/23.
//

import UIKit

extension UIView {
    func shake(for duration: TimeInterval = 2, withTranslation translation: CGFloat = 10) {
        let propertyAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 0.5) {
            self.transform = CGAffineTransform(translationX: translation, y: 0)
        }

        propertyAnimator.addAnimations({
            self.transform = CGAffineTransform(translationX: 0, y: 0)
        }, delayFactor: 0.3)

        propertyAnimator.startAnimation()
    }
  
  
  
  //  func beep() {
  //      let systemSoundID : SystemSoundID = 1015     // Great one ; 1016 is bip-bip
  //      AudioServicesPlayAlertSound(systemSoundID)
  //  }
}
