//
//  FeedLoaderPresentationAdaptor.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 12/05/2023.
//

import EssentialFeed

final class FeedLoaderPresentationAdaptor {
    private let loader: FeedLoader
    private let presenter: FeedViewPresenter
    
    init(loader: FeedLoader, presenter: FeedViewPresenter) {
        self.loader = loader
        self.presenter = presenter
    }
    
    func loadFeed() {
        presenter.didStartLoadingFeed()
        loader.load { [weak self] result in
            switch result {
            case .success(let feed):
                self?.presenter.didCompleteLoadingFeed(with: feed)
            case .failure(let error):
                self?.presenter.didEndLoadingFeed(with: error)
            }
        }
    }
}
