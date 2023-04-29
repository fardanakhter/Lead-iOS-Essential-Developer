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
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let refreshController = FeedRefreshViewController(feedLoader: feedLoader)
        let feedViewController = FeedViewController(refreshControl: refreshController)
        refreshController.onRefresh = { [weak feedViewController] images in
            feedViewController?.tableModels = images.map {
                FeedImageCellController(model: $0, imageLoader: imageLoader)
            }
        }
        return feedViewController
    }
}
