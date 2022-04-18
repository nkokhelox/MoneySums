//
//  UIScene+util.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2022/04/18.
//

import Foundation
import UIKit

extension UIWindowScene {
    func addBlurViews(blurViewTag: Int = Int.max, subview: UIView? = nil) {
        windows.forEach { window in
            if window.viewWithTag(Int.max) == nil && window.viewWithTag(Int.min) == nil {
                let blurEffect: UIBlurEffect
                if #available(iOS 13.0, *) {
                    blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
                } else {
                    blurEffect = UIBlurEffect(style: .light)
                }

                let blurEffectView = UIVisualEffectView(effect: blurEffect)
                blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                blurEffectView.frame = window.frame
                blurEffectView.isOpaque = false

                let windowCenter = CGPoint(x: window.frame.width / 2.0, y: window.frame.height / 2.0)

                let overlayView = UIView()
                overlayView.frame = CGRect(x: 0, y: 0, width: window.frame.width, height: window.frame.height)
                overlayView.backgroundColor = UIColor.clear
                overlayView.center = windowCenter
                overlayView.clipsToBounds = true
                overlayView.addSubview(blurEffectView)
                overlayView.tag = blurViewTag

                if let blurSubview = subview {
                    overlayView.addSubview(blurSubview)
                } else {
                    let label = UILabel()
                    label.frame = CGRect(x: 0, y: 0, width: window.frame.width, height: 80)
                    label.textColor = UIColor.adaTranslucent
                    label.backgroundColor = UIColor.clear
                    label.center = windowCenter
                    label.clipsToBounds = true
                    label.textAlignment = .center
                    label.text = "μ°"

                    overlayView.addSubview(label)
                }

                window.addSubview(overlayView)
            }
        }
    }

    func removeBlurViews(blurViewTag: Int = Int.max) {
        windows.forEach { window in
            if let blurView = window.viewWithTag(blurViewTag) {
                UIView.animate(withDuration: 0.2) {
                    blurView.alpha = 0.0
                } completion: { _ in
                    blurView.removeFromSuperview()
                }
            }
        }
    }
}
