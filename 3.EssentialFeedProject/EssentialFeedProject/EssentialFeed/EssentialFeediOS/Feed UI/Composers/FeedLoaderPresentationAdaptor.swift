//
//  FeedLoaderPresentationAdaptor.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 12/05/2023.
//

import EssentialFeed

final class FeedLoaderPresentationAdaptor: FeedRefreshViewControllerDelegate {
    private let loader: FeedLoader
    var presenter: FeedViewPresenter?
    
    init(loader: FeedLoader) {
        self.loader = loader
    }
    
    func didStartLoadingFeed() {
        presenter?.didStartLoadingFeed()
        loader.load { [weak self] result in
            switch result {
            case .success(let feed):
                self?.presenter?.didCompleteLoadingFeed(with: feed)
            case .failure(let error):
                self?.presenter?.didEndLoadingFeed(with: error)
            }
        }
    }
}
