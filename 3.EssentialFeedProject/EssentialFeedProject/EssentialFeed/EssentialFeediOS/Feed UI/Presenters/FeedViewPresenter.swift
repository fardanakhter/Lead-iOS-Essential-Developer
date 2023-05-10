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
        NSLocalizedString("FEED_VIEW_TITLE",
                          tableName: "Feed",
                          bundle: Bundle(for: FeedViewPresenter.self),
                          comment: "Title for Feed View")
    }
    
    func loadFeed() {
        feedLoadingView?.display(FeedLoadingViewModel(isLoading: true))
        feedLoader?.load { [weak self] result in
            guard Thread.isMainThread else {
                DispatchQueue.main.async { self?.handleFeedResult(result) }
                return
            }
            self?.handleFeedResult(result)
        }
    }
    
    private func handleFeedResult(_ result: FeedLoader.Result) {
        if case let .success(images) = result {
            feedView?.display(FeedViewModel(feed: images))
        }
        feedLoadingView?.display(FeedLoadingViewModel(isLoading: false))
    }
}
