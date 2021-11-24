//
//  UITableView+util.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2021/09/26.
//

import UIKit
extension UITableView {
    func reloadData(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0, animations: reloadData)
            { _ in completion() }
    }
}
