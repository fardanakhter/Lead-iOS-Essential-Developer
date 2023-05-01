//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 28/04/2023.
//

import Foundation
import UIKit

final class FeedImageCellController {
    private let viewModel: FeedImageCellViewModel<UIImage>
    
    init(viewModel: FeedImageCellViewModel<UIImage>){
        self.viewModel = viewModel
    }
    
    func view() -> UITableViewCell {
        let view = binded(FeedImageCell())
        viewModel.loadImage()
        return view
    }
    
    private func binded(_ view: FeedImageCell) -> UITableViewCell {
        view.imageDescription = viewModel.description
        view.location = viewModel.location
        view.locationContainer.isHidden = !viewModel.hasLocation
        
        viewModel.onImageLoad = { [weak view] image in
            view?.feedImageView.image = image
        }
        
        viewModel.onShouldRetryLoadingStateChange = { [weak view] shouldRetry in
            view?.retryImageLoad.isHidden = !shouldRetry
        }
        
        view.retryImageAction = viewModel.loadImage
        
        return view
    }
    
    func preload() {
        viewModel.loadImageData()
    }
    
    func cancelTask() {
        viewModel.cancelImageData()
    }
}
