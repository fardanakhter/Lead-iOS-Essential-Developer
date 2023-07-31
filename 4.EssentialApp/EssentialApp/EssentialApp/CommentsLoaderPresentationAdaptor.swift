//
//  CommentsLoaderPresentationAdaptor.swift
//  EssentialApp
//
//  Created by Fardan Akhter on 31/07/2023.
//

import Foundation
import EssentialFeed
import EssentialFeediOS

final class CommentsLoaderPresentationAdaptor: ListRefreshViewControllerDelegate {
    private let loader: ImageCommentLoader
    var presenter: LoadResourcePresenter<[ImageComment], CommentsViewAdapter>?
    
    init(loader: ImageCommentLoader) {
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
