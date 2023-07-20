//
//  FeedLoaderPresentationAdaptor.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 12/05/2023.
//

import EssentialFeed
import EssentialFeediOS

final class FeedLoaderPresentationAdaptor: ListRefreshViewControllerDelegate {
    private let loader: FeedLoader
    var presenter: LoadResourcePresenter<[FeedImage], FeedViewAdapter>?
    
    init(loader: FeedLoader) {
        self.loader = loader
    }
    
    func didStartLoadingList() {
        presenter?.didStartLoadingResource()
        loader.load { [weak self] result in
            switch result {
            case .success(let feed):
                self?.presenter?.didCompleteLoading(with: feed)
            case .failure(let error):
                self?.presenter?.didCompleteLoadingResource(with: error)
            }
        }
    }
}
