//
//  LoadMoreFeedCell.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 10/08/2023.
//

import Foundation
import UIKit

public class LoadMoreFeedCell: UITableViewCell {
    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        contentView.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                                     spinner.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)])
        return spinner
    }()
    
    public var isLoading: Bool {
        get {
            spinner.isAnimating
        }
        set {
            if newValue { spinner.startAnimating() }
            else { spinner.stopAnimating() }
        }
    }
}
