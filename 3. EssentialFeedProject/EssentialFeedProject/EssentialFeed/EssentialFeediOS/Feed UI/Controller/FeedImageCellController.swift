//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 28/04/2023.
//

import Foundation
import EssentialFeed
import UIKit

final class FeedImageCellController {
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader){
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func view() -> UITableViewCell {
        let view = FeedImageCell()
        view.imageDescription = model.description
        view.location = model.location
        view.locationContainer.isHidden = model.location == nil
        view.retryImageLoad.isHidden = true
        view.feedImageView.image = nil
        
        let imageLoad = { [weak self, weak view] in
            guard let self else {return}
            
            self.task = self.imageLoader.load(model.url) { [weak view] result in
                let data = (try? result.get()) ?? nil
                let image = data.map{UIImage(data: $0)} ?? nil
                view?.feedImageView.image = image
                view?.retryImageLoad.isHidden = image != nil
            }
        }
        
        view.retryImageAction = imageLoad
        imageLoad()
        
        return view
    }
    
    func preload() {
        task = imageLoader.load(model.url) { _ in }
    }
    
    deinit {
        task?.cancel()
    }
}
