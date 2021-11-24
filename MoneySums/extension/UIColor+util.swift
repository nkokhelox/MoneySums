//
//  UIColor+util.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2021/09/18.
//

import UIKit

extension UIColor {
    static let adaGrey = UIColor(named: "adaGrey") ?? systemGray
    static let adaTeal = UIColor(named: "adaTeal") ?? systemTeal
    static let adaOrange = UIColor(named: "adaOrange") ?? systemOrange
    static let blackOrWhite = UIColor(named: "blackOrWhite") ?? white
    static let adaAccentColor = UIColor(named: "accentColor") ?? label
    static let adaTranslucent = UIColor(named: "adaTranslucent") ?? blackOrWhite

    static let chartColors = [systemRed, systemOrange, systemYellow, systemGreen, systemBlue, systemIndigo, systemPurple, systemIndigo]

    /**
     Create a lighter color
     */
    func lighter(by percentage: CGFloat = 30.0) -> UIColor {
        return adjustBrightness(by: abs(percentage))
    }

    /**
     Create a darker color
     */
    func darker(by percentage: CGFloat = 30.0) -> UIColor {
        return adjustBrightness(by: -abs(percentage))
    }

    /**
     Try to increase brightness or decrease saturation
     */
    private func adjustBrightness(by percentage: CGFloat = 30.0) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            if b < 1.0 {
                let newB: CGFloat = max(min(b + (percentage / 100.0) * b, 1.0), 0.0)
                return UIColor(hue: h, saturation: s, brightness: newB, alpha: a)
            } else {
                let newS: CGFloat = min(max(s - (percentage / 100.0) * s, 0.0), 1.0)
                return UIColor(hue: h, saturation: newS, brightness: b, alpha: a)
            }
        }
        return self
    }
}
