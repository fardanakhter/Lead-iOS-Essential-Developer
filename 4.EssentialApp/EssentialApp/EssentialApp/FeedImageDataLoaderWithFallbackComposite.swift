//
//  FeedImageDataLoaderWithFallbackComposite.swift
//  EssentialApp
//
//  Created by Fardan Akhter on 24/05/2023.
//

import EssentialFeed

public class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    private let primaryLoader: FeedImageDataLoader
    private let fallbackLoader: FeedImageDataLoader
    
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
    
    public init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        primaryLoader = primary
        fallbackLoader = fallback
    }
    
    public func load(_ url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> FeedImageDataLoaderTask {
        let task = TaskWrapper(callback: completion)
        
        task.wrapper = primaryLoader.load(url) { [weak self] primaryResult in
            switch primaryResult {
            case let .success(primaryFeed):
                task.complete(with: .success(primaryFeed))
                
            case .failure:
                task.wrapper = self?.fallbackLoader.load(url, completion: { fallbackResult in
                    task.complete(with: fallbackResult)
                })
            }
        }
        return task
    }
}

