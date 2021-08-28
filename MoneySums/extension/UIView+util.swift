//
//  UIViewExtension.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2021/08/23.
//

import UIKit
import AudioToolbox

extension UIView {
  func shake(for duration: TimeInterval = 0.5, withTranslation translation: CGFloat = 10) {
    func slideRightAnimation() {
      self.transform = CGAffineTransform(translationX: translation, y: 0)
    }
    
    func restoreOrigin() {
      self.transform = CGAffineTransform(translationX: 0, y: 0)
    }
    
    let propertyAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 0.5, animations: slideRightAnimation)
    
    propertyAnimator.addAnimations(restoreOrigin, delayFactor: 0.3)
    propertyAnimator.addAnimations(slideRightAnimation, delayFactor: 0.5)
    propertyAnimator.addAnimations(restoreOrigin, delayFactor: 0.8)
    
    propertyAnimator.startAnimation()
  }
}
