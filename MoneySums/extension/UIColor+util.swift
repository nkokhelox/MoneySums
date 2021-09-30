//
//  UIColor+util.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2021/09/18.
//

import UIKit

extension UIColor {
  static let adaGrey = UIColor(named: "adaGrey")
  static let adaTeal = UIColor(named: "adaTeal")
  static let adaOrange = UIColor(named: "adaOrange")
  static let adaAccentColor = UIColor(named: "accentColor")
  
  static func randomColor(alpha: CGFloat = 1) -> UIColor {
    let red = Double(arc4random_uniform(256))
    let green = Double(arc4random_uniform(256))
    let blue = Double(arc4random_uniform(256))
    return UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: alpha)
  }
}
