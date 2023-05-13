//
//  FeedViewAdaptor.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 11/05/2023.
//

import UIKit
import EssentialFeed

final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let imageDataLoader: FeedImageDataLoader
    
    init(controller: FeedViewController, imageDataLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageDataLoader = imageDataLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.tableModels = viewModel.feed.map {
            let presentationAdaptor = FeedImageLoaderPresentationAdaptor(model: $0, loader: imageDataLoader)
            
            let controller = FeedImageCellController()
            controller.delegate = presentationAdaptor
            
            let presenter = FeedImageViewPresenter<WeakRefProxyInstance<FeedImageCellController>, UIImage>(view: WeakRefProxyInstance(controller))
            presentationAdaptor.presenter = presenter
            
            return controller
        }
    }
}
