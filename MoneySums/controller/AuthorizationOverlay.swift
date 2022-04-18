//
//  L.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2021/10/06.
//

import LocalAuthentication
import UIKit

public class AuthorizationOverlay {
    class var shared: AuthorizationOverlay {
        struct Static {
            static let instance: AuthorizationOverlay = AuthorizationOverlay()
        }
        return Static.instance
    }

    public func showOverlay(doAuthPrompt: Bool = false) {
        guard let windowScene = (UIApplication.shared.connectedScenes.first as? UIWindowScene),
              let window = windowScene.windows.first else {
            return
        }

        let authorizeUserAction = UIAction { _ in
            self.authorizeDeviceOwner()
        }
      
        let windowCenter = CGPoint(x: window.frame.width / 2.0, y: window.frame.height / 2.0)

        let authorizeButton = UIButton(type: .system, primaryAction: authorizeUserAction)
        authorizeButton.setImage(UIImage(systemName: "lock.shield"), for: .normal)
        authorizeButton.frame = CGRect(x: 0, y: 0, width: 120, height: 80)
        authorizeButton.backgroundColor = UIColor.blackOrWhite
        authorizeButton.setTitle("Unlock", for: .normal)
        authorizeButton.layer.cornerRadius = 10
        authorizeButton.center = windowCenter
        authorizeButton.clipsToBounds = true
      
      windowScene.addBlurViews(blurViewTag: Int.min, subview: authorizeButton)

        if doAuthPrompt {
            authorizeDeviceOwner()
        }
    }

    public func hideOverlayView() {
        DispatchQueue.main.async {
            (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.removeBlurViews(blurViewTag: Int.min)
        }
    }

    func authorizeDeviceOwner() {
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = "Please use your Passcode"

        var authorizationError: NSError?
        let reason = "Authentication required to grant you access to the private data"

        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authorizationError) {
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, _ in
                if success {
                    self.hideOverlayView()
                }
            }
        }
    }
}
