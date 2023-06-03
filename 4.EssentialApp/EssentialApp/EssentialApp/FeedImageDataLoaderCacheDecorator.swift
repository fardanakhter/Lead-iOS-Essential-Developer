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
    
    public init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func load(_ url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> FeedImageDataLoaderTask {
        return decoratee.load(url) {[weak self] result in
            completion(result.map {
                self?.cache.saveIgnoringResult($0, for: url)
                return $0
            })
        }
    }
}

private extension FeedImageDataCache {
    func saveIgnoringResult(_ data: Data, for url: URL) {
        save(data, with: url){ _ in }
    }
}
