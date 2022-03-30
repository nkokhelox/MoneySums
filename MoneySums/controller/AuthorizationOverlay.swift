//
//  L.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2021/10/06.
//

import LocalAuthentication
import UIKit

public class AuthorizationOverlay {
    var overlayView = UIView()

    class var shared: AuthorizationOverlay {
        struct Static {
            static let instance: AuthorizationOverlay = AuthorizationOverlay()
        }
        return Static.instance
    }

  public func showOverlay(isDarkModeEnabled: Bool, doAuthPrompt: Bool = false) {
        guard let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first
        else {
            return
        }
        let windowCenter = CGPoint(x: window.frame.width / 2.0, y: window.frame.height / 2.0)
        overlayView.frame = CGRect(x: 0, y: 0, width: window.frame.width, height: window.frame.height)
        overlayView.backgroundColor = UIColor.clear
        overlayView.center = windowCenter
        overlayView.clipsToBounds = true

        let blur = UIBlurEffect(style: isDarkModeEnabled ? .dark : .light)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = overlayView.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.isOpaque = false
        overlayView.addSubview(blurView)

        let authorizeUserAction = UIAction { action in
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
    
    if (doAuthPrompt) {
      self.authorizeDeviceOwner()
    }
    }

    public func hideOverlayView() {
        DispatchQueue.main.async {
            self.overlayView.removeFromSuperview()
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
