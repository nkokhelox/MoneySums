//
//  SectionHeaderFooterGestureRecognizer.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2021/11/28.
//

import UIKit

class OnSectionHeaderFooterTap: UITapGestureRecognizer {
  private(set) var section: Int
  
  required init(section: Int, target: Any?, action: Selector?) {
    self.section = section
    super.init(target: target, action: action)
  }
}
