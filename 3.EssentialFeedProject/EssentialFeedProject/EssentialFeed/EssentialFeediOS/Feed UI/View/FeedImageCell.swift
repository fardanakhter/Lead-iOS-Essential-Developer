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
    @IBOutlet public private(set) var retryImageButton: UIButton!
    
    var retryImageAction: (() -> Void)?
    
    @IBAction private func retryImageLoading() {
        retryImageAction?()
    }
}
