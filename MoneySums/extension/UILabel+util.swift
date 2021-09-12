//
//  UILabel+util.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2021/09/12.
//

import UIKit

extension UILabel {
    func setMargins(_ margin: CGFloat = 15) {
        if let textString = self.text {
          let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.firstLineHeadIndent = margin
            paragraphStyle.headIndent = margin
            paragraphStyle.tailIndent = -margin
            let attributedString = NSMutableAttributedString(string: textString)
            attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
            attributedText = attributedString
        }
    }
}
