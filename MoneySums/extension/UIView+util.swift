//
//  UIViewExtension.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2021/08/23.
//

import UIKit
import AudioToolbox

extension UIView {
  func shake() {
    func slideRightAnimation() {
      self.transform = CGAffineTransform(translationX: 30, y: 0)
    }
    
    func restoreOrigin() {
      self.transform = CGAffineTransform(translationX: 0, y: 0)
    }
    
    func slideLeftAnimation() {
      self.transform = CGAffineTransform(translationX: -30, y: 0)
    }
        
    let propertyAnimator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.5, animations: slideRightAnimation)
    propertyAnimator.addAnimations(slideLeftAnimation, delayFactor: 0.3)
    propertyAnimator.addAnimations(restoreOrigin, delayFactor: 0.6)
    propertyAnimator.startAnimation()
  }
}
