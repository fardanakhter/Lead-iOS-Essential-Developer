//
//  MainQueueDispatchDecorator.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 11/05/2023.
//

import EssentialFeed

final class MainQueueDispatchDecorator<T> {
    private let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(_ completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { completion() }
            return
        }
        completion()
    }
}

extension MainQueueDispatchDecorator: FeedLoader where T == FeedLoader {
    func load(completion: @escaping (Result<[FeedImage], Error>) -> Void) {
        decoratee.load {[weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: FeedImageDataLoader where T == FeedImageDataLoader {
    func load(_ url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> FeedImageDataLoaderTask {
        decoratee.load(url) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: ImageCommentLoader where T == ImageCommentLoader {
    func load(completion: @escaping (Result<[ImageComment], Error>) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
