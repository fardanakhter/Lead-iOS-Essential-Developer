//
//  CommentsLoaderPresentationAdaptor.swift
//  EssentialApp
//
//  Created by Fardan Akhter on 31/07/2023.
//

import Combine
import EssentialFeed
import EssentialFeediOS

final class CommentsLoaderPresentationAdaptor: ListRefreshViewControllerDelegate {
    
    private struct ImageCommentLoaderDecorator {
        private let decoratee: ImageCommentLoader
        
        init(decoratee: ImageCommentLoader) {
            self.decoratee = decoratee
        }
        
        func loadPublisher() -> AnyPublisher<[ImageComment], Swift.Error> {
            Future(decoratee.load).eraseToAnyPublisher()
        }
    }
    
    private var cancellable: Set<AnyCancellable> = .init()
    private var loader: ImageCommentLoaderDecorator
    
    var presenter: LoadResourcePresenter<[ImageComment], CommentsViewAdapter>?
    
    init(loader: ImageCommentLoader) {
        self.loader = ImageCommentLoaderDecorator(decoratee: loader)
    }
    
    func didStartLoadingList() {
        presenter?.didStartLoadingResource()
        loader.loadPublisher()
            .sink { [weak self] completion in
                guard let self else { return }
                if case let .failure(error) = completion {
                    self.presenter?.didCompleteLoadingResource(with: error)
                }
            } receiveValue: { [weak self] feed in
                guard let self else { return }
                self.presenter?.didCompleteLoading(with: feed)
            }
            .store(in: &cancellable)
    }
}
