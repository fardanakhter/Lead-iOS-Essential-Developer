//
//  LocalFeedCache.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 01/04/2023.
//

import Foundation

public class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: Date
    
    public init(store: FeedStore, timestamp: () -> Date) {
        self.store = store
        self.currentDate = timestamp()
    }
}

extension LocalFeedLoader: FeedCache {
    public typealias SaveResult = Result<Void,Error>
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteFeedCache { [weak self] deletionResult in
            guard let self else { return }
            
            switch deletionResult {
            case .success(()):
                self.cache(feed, with: currentDate, OnCompletion: completion)
            
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    private func cache(_ feed: [FeedImage], with timestamp: Date, OnCompletion completion: @escaping (SaveResult) -> Void) {
        self.store.insertFeedCache(with: feed.toLocalFeed(), and: timestamp) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

extension LocalFeedLoader: FeedLoader {
    public typealias LoadResult = FeedLoader.Result
    public func load(completion: @escaping (LoadResult) -> Void) {
        self.store.loadFeedCache { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
    
            case let .success(.some(cachedFeed)) where FeedCachePolicy.validate(cachedFeed.timestamp, against: currentDate):
                completion(.success(cachedFeed.feed.toModels()))
            
            case .success:
                completion(.success([]))
            }
        }
    }
}
   
extension LocalFeedLoader {
    public func validateCache() {
        self.store.loadFeedCache { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .failure(_):
                self.store.deleteFeedCache(completion: { _ in })
            
            case let .success(.some(cachedFeed)) where !FeedCachePolicy.validate(cachedFeed.timestamp, against: currentDate):
                self.store.deleteFeedCache(completion: { _ in })
            
            case .success:
                break
            }
        }
    }
}

extension Array where Element == FeedImage {
    func toLocalFeed() -> [LocalFeedImage] {
        self.map{ LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}

extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        self.map{ FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}
