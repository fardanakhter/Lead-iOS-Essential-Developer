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
            let presenter = FeedImageViewPresenter<FeedImageCellController, UIImage>(model: $0, imageLoader: imageDataLoader, imageTransformer: { UIImage(data: $0) })
            let controller = FeedImageCellController(presenter: presenter)
            presenter.view = controller
            return controller
        }
    }
}
