//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 29/04/2023.
//

import Foundation
import UIKit
import EssentialFeed

public class FeedUIComposer {
    private init() {}
    
    public static func feedUIComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedPresenter = FeedViewPresenter(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(presenter: feedPresenter)
        let feedViewController = FeedViewController(refreshControl: refreshController)
        feedPresenter.feedLoadingView = refreshController
        feedPresenter.feedView = FeedViewAdapter(controller: feedViewController, imageDataLoader: imageLoader)
        return feedViewController
    }
}

final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let imageDataLoader: FeedImageDataLoader
    
    init(controller: FeedViewController, imageDataLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageDataLoader = imageDataLoader
    }
    
    func display(loadFeed: [FeedImage]) {
        controller?.tableModels = loadFeed.map {
            let feedCellViewModel = FeedImageCellViewModel(model: $0, imageLoader: imageDataLoader, imageTransformer: { UIImage(data: $0) })
            return FeedImageCellController(viewModel: feedCellViewModel)
        }
    }
}
