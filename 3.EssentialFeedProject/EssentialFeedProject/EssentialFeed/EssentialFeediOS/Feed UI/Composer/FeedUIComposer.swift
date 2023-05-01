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
        let feedViewModel = FeedViewModel(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(viewModel: feedViewModel)
        let feedViewController = FeedViewController(refreshControl: refreshController)
        feedViewModel.onFeedLoad = { [weak feedViewController] images in
            feedViewController?.tableModels = images.map {
                let feedCellViewModel = FeedImageCellViewModel(model: $0, imageLoader: imageLoader, imageTransformer: { UIImage(data: $0) })
                return FeedImageCellController(viewModel: feedCellViewModel)
            }
        }
        return feedViewController
    }
}
