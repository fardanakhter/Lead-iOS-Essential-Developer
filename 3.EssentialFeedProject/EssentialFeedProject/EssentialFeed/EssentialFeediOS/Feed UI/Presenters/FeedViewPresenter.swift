//
//  FeedViewPresenter.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 03/05/2023.
//

import Foundation
import EssentialFeed

protocol FeedView {
    func display(loadFeed: [FeedImage])
}

protocol FeedLoadingView: AnyObject {
    func display(isLoading: Bool)
}

final class FeedViewPresenter {
    private var feedLoader: FeedLoader?
    
    var feedView: FeedView?
    weak var feedLoadingView: FeedLoadingView?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    @objc func refreshFeed() {
        feedLoadingView?.display(isLoading: true)
        feedLoader?.load { [weak self] result in
            if case let .success(images) = result {
                self?.feedView?.display(loadFeed: images)
            }
            self?.feedLoadingView?.display(isLoading: false)
        }
    }
}
