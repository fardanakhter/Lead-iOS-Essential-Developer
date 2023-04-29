//
//  FeedView.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 25/04/2023.
//

import Foundation
import UIKit

public class FeedImageCell: UITableViewCell {
    public var locationContainer: UIView = UIView()
    public var imageDescription: String? = ""
    public var location: String? = ""
    public var feedImageView: UIImageView = UIImageView()
    
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
