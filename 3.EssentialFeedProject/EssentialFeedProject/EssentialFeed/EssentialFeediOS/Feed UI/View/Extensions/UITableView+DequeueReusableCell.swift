//
//  UITableView+DequeueReusableCell.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 05/05/2023.
//

import Foundation
import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        let cell = dequeueReusableCell(withIdentifier: identifier) as! T
        return cell
    }
}
