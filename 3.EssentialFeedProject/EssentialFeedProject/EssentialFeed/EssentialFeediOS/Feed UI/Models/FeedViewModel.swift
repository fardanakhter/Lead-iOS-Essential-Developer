//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 01/05/2023.
//

import Foundation
import EssentialFeed

final class FeedViewModel {
    typealias Observer<T> = (T) -> Void
    
    private var feedLoader: FeedLoader?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onLoadingStateChange: Observer<Bool>?
    var onFeedLoad: Observer<[FeedImage]>?
    
    @objc func loadFeed() {
        onLoadingStateChange?(true)
        feedLoader?.load { [weak self] result in
            if case let .success(images) = result {
                self?.onFeedLoad?(images)
            }
            self?.onLoadingStateChange?(false)
        }
    }
}
