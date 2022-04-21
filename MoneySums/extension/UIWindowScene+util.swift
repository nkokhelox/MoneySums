//
//  UIScene+util.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2022/04/18.
//

import LocalAuthentication
import UIKit

// MARK: - App lock

extension UIWindowScene: AppLockDelegate {
    func lockApp(authorizeNow: Bool = false, isManuallyLocked: Bool = false) {
        windows.forEach { window in
            if window.viewWithTag(Int.min) == nil {
                if isManuallyLocked {
                    UserDefaults.standard.appIsManuallyLocked()
                }

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
                overlayView.tag = Int.min

                let authorizeUserAction = UIAction { _ in
                    self.authorizeDeviceOwner()
                }

                let authorizeButton = UIButton(type: .system, primaryAction: authorizeUserAction)
                authorizeButton.setImage(UIImage(systemName: "lock.shield"), for: .normal)
                authorizeButton.frame = CGRect(x: 0, y: 0, width: 120, height: 80)
                authorizeButton.backgroundColor = UIColor.blackOrWhite
                authorizeButton.setTitle("Unlock", for: .normal)
                authorizeButton.layer.cornerRadius = 10
                authorizeButton.center = windowCenter
                authorizeButton.clipsToBounds = true

                overlayView.addSubview(authorizeButton)

                window.addSubview(overlayView)

                if authorizeNow {
                    self.authorizeDeviceOwner()
                }
            }
        }
    }

    func willEnterForeground() {
        if UserDefaults.standard.remainLocked() {
            return
        } else {
            unlockApp()
        }
    }

    func unlockApp() {
        UserDefaults.standard.unlockApp()
        windows.forEach { window in
            if let blurView = window.viewWithTag(Int.min) {
                blurView.removeFromSuperview()
            }
        }
    }

    private func authorizeDeviceOwner() {
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = "Please use your Passcode"

        var authorizationError: NSError?
        let reason = "Authentication required to grant you access to the private data"

        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authorizationError) {
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, _ in
                if success {
                    DispatchQueue.main.async {
                        self.unlockApp()
                    }
                }
            }
        }
    }
}
