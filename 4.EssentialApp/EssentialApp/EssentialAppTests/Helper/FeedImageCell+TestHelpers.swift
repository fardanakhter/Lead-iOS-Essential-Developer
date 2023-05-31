//
//  FeedImageCell+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Fardan Akhter on 08/05/2023.
//

import Foundation
import EssentialFeediOS

extension FeedImageCell {
    var isShowingLocation: Bool {
        !locationContainer.isHidden
    }
    
    var isShowingRetryOptionView: Bool {
        !retryImageButton.isHidden
    }
    
    var renderedImage: Data? {
        feedImageView.image?.pngData()
    }
    
    func simulateRetryImageLoad() {
        retryImageButton.simulateRetryImageLoad()
    }
}
