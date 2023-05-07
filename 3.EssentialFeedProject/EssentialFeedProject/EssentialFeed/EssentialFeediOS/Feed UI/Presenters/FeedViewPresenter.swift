//
//  FeedViewPresenter.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 03/05/2023.
//

import Foundation
import EssentialFeed

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

final class FeedViewPresenter {
    private var feedLoader: FeedLoader?
    
    var feedView: FeedView?
    var feedLoadingView: FeedLoadingView?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    static var feedViewTitle: String {
        "My Feed"
    }
    
    func loadFeed() {
        feedLoadingView?.display(FeedLoadingViewModel(isLoading: true))
        feedLoader?.load { [weak self] result in
            if case let .success(images) = result {
                self?.feedView?.display(FeedViewModel(feed: images))
            }
            self?.feedLoadingView?.display(FeedLoadingViewModel(isLoading: false))
        }
    }
}
