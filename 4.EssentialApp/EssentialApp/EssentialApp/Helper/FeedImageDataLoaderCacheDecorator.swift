//
//  FeedImageDataLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Fardan Akhter on 27/05/2023.
//

import EssentialFeed

public class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    private let decoratee: FeedImageDataLoader
    private let cache: FeedImageDataCache
    
    private class TaskWrapper: FeedImageDataLoaderTask {
        private var callback: ((FeedImageDataLoader.Result) -> Void)?
        var wrapper: FeedImageDataLoaderTask?
        
        init(callback: @escaping ((FeedImageDataLoader.Result) -> Void)) {
            self.callback = callback
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            callback?(result)
        }
        
        func cancel() {
            wrapper?.cancel()
            wrapper = nil
            callback = nil
        }
    }
    
    public init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func load(_ url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> FeedImageDataLoaderTask {
        let task = TaskWrapper(callback: completion)
        task.wrapper = decoratee.load(url) {[weak self] result in
            task.complete(with: result.map {
                self?.cache.save($0, with: url){ _ in }
                return $0
            })
        }
        return task
    }
}
