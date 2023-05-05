//
//  FeedView.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 25/04/2023.
//

import Foundation
import UIKit

public class FeedImageCell: UITableViewCell {
    @IBOutlet public private(set) var locationContainer: UIView!
    @IBOutlet public private(set) var imageDescription: UILabel!
    @IBOutlet public private(set) var location: UILabel!
    @IBOutlet public private(set) var feedImageView: UIImageView!
    
    lazy public var retryImageLoad: UIButton = {
       let button = UIButton()
        button.addTarget(self, action: #selector(retryImageLoading), for: .touchUpInside)
        return button
    }()
    
    var retryImageAction: (() -> Void)?
    
    @objc private func retryImageLoading() {
        retryImageAction?()
    }
}
