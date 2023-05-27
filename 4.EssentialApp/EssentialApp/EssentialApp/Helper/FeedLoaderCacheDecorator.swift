//
//  FeedLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Fardan Akhter on 27/05/2023.
//

import EssentialFeed

public class FeedLoaderCacheDecorator: FeedLoader {
    private let decoratee: FeedLoader
    private let cache: FeedCache
    
    public init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func load(completion: @escaping (Result<[FeedImage], Error>) -> Void) {
        decoratee.load {[weak self] result in
            completion(result.map{
                self?.cache.save($0) { _ in }
                return $0
            })
        }
    }
}
