//
//  LoadResourcePresenter.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 13/07/2023.
//

import Foundation

public final class LoadResourcePresenter {
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    
    public init(feedView: FeedView, loadingView: FeedLoadingView) {
        self.feedView = feedView
        self.loadingView = loadingView
    }
    
   public static var feedViewTitle: String {
        NSLocalizedString("FEED_VIEW_TITLE",
                          tableName: "Feed",
                          bundle: Bundle(for: FeedViewPresenter.self),
                          comment: "Title for Feed View")
    }
    
    public func didStartLoadingFeed() {
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    public func didCompleteLoadingFeed(with feed: [FeedImage]) {
        loadingView.display(FeedLoadingViewModel(isLoading: false))
        feedView.display(FeedViewModel(feed: feed))
    }
    
    public func didCompleteLoadingFeed(with error: Error) {
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
