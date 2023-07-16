//
//  FeedViewPresenter.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 13/05/2023.
//

import Foundation

public protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

public final class FeedViewPresenter {
    private let feedView: FeedView
    private let loadingView: ResourceLoadingView
    
    public init(feedView: FeedView, loadingView: ResourceLoadingView) {
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
        loadingView.display(ResourceLoadingViewModel(isLoading: true))
    }
    
    public func didCompleteLoadingFeed(with feed: [FeedImage]) {
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
        feedView.display(Self.map(feed))
    }
    
    public func didCompleteLoadingFeed(with error: Error) {
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
    
    static public func map(_ feed: [FeedImage]) -> FeedViewModel {
        return FeedViewModel(feed: feed)
    }
}
