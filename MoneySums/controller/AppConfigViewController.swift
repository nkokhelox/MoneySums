//
//  AppConfigViewController.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2022/03/13.
//

import UIKit

class AppConfigViewController: UIViewController {
    var appLockDelegate: AppLockDelegate?
    @IBOutlet var thirdPartyComponents: UILabel!
    @IBOutlet var appIconSegment: UISegmentedControl!
    @IBOutlet var autoDeleteAmountPeriod: UISegmentedControl!

    @IBAction func appIconChanged(_ sender: Any) {
        UserDefaults.standard.setCurrentAppIcon(option: appIconSegment.selectedSegmentIndex)
        refreshAppIcon()
    }

    @IBAction func deleteAmountChanged(_ sender: Any) {
        UserDefaults.standard.setPaidAmountRetention(option: autoDeleteAmountPeriod.selectedSegmentIndex)
        let option = autoDeleteAmountPeriod.selectedSegmentIndex
        var alert: UIAlertController?

        switch option {
        case 0:
            alert = UIAlertController(title: nil, message: "Paid amount will NEVER be deleted.", preferredStyle: .alert)
            break
        default:
            let duration = autoDeleteAmountPeriod.titleForSegment(at: option) ?? "some option \(option)"
            alert = UIAlertController(title: nil, message: "Paid amount will auto-delete after \(duration).", preferredStyle: .alert)
        }

        alert?.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in self.dismiss(animated: true) }))
        present(alert!, animated: true)
    }

  private func showAuthorizationOverlay(promptUserAuth: Bool = false) {
      AuthorizationOverlay.shared.showOverlay(isDarkModeEnabled: traitCollection.userInterfaceStyle == .dark, doAuthPrompt: promptUserAuth)
  }
  
    @IBAction func lockApp(_ sender: Any) {
        dismiss(animated: true)
        appLockDelegate?.lockNow()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        appIconSegment.selectedSegmentIndex = UserDefaults.standard.getCurrentAppIcon()
        autoDeleteAmountPeriod.selectedSegmentIndex = UserDefaults.standard.getPaidAmountRetentionMonths()
        thirdPartyComponents.text = "Version \(Bundle.main.appVersion) (\(Bundle.main.appBuild))\nUsed frameworks:\n\u{2022}DVPieChart\n\u{2022}RealmSwift"
    }

    func setAppIconChoice(_ choice: Int) {
        UserDefaults.standard.set(choice, forKey: UserDefaults.APP_ICON_KEY)
        refreshAppIcon()
    }

    func refreshAppIcon() {
        if #available(iOS 13, *) {
            switch UserDefaults.standard.getCurrentAppIcon() {
            case 0: self.clearAltIcon(); break
            default: self.setLightIcon(); break
            }

            appIconSegment.selectedSegmentIndex = UserDefaults.standard.getCurrentAppIcon()
        }
    }

    func setLightIcon() {
        if UIApplication.shared.alternateIconName != "lightMode" {
            UIApplication.shared.setAlternateIconName("lightMode") { error in
                if let clearError = error {
                    print("Failed to set the alternative app icon name: \(clearError)")
                } else {
                    self.dismiss(animated: true)
                }
            }
        }
    }

    func clearAltIcon() {
        if UIApplication.shared.alternateIconName != nil {
            UIApplication.shared.setAlternateIconName(nil) { error in
                if let clearError = error {
                    print("Failed to clear the alternative app icon name: \(clearError)")
                } else {
                    self.dismiss(animated: true)
                }
            }
        }
    }
}
