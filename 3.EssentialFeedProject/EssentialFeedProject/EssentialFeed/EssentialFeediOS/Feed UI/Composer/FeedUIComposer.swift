//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 29/04/2023.
//

import Foundation
import EssentialFeed

public class FeedUIComposer {
    private init() {}
    
    public static func feedUIComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedViewModel = FeedViewModel(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(viewModel: feedViewModel)
        let feedViewController = FeedViewController(refreshControl: refreshController)
        feedViewModel.onFeedLoad = { [weak feedViewController] images in
            feedViewController?.tableModels = images.map {
                FeedImageCellController(model: $0, imageLoader: imageLoader)
            }
        }
        return feedViewController
    }
}
