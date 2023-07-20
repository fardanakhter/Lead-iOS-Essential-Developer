//
//  FeedViewAdaptor.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 11/05/2023.ç
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewAdapter: ResourceView {
    private weak var controller: ListViewController?
    private let imageDataLoader: FeedImageDataLoader
    
    init(controller: ListViewController, imageDataLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageDataLoader = imageDataLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.display( viewModel.feed.map {
            let presentationAdaptor = FeedImageLoaderPresentationAdaptor(model: $0, loader: imageDataLoader)
            
            let controller = FeedImageCellController()
            controller.delegate = presentationAdaptor
            
            let presenter = FeedImageViewPresenter<WeakFeedImageCellController, UIImage>(view: WeakFeedImageCellController(controller))
            presentationAdaptor.presenter = presenter
            
            return controller
        })
    }
}
