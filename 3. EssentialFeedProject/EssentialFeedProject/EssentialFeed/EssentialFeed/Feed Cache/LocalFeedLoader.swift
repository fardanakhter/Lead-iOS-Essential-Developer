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

extension LocalFeedLoader {
    public typealias SaveResult = Error?
    public func save(_ feed: [FeedImage], completion: @escaping (Error?) -> Void) {
        store.deleteFeedCache { [weak self] error in
            guard let self else { return }
            
            if let deletionError = error {
                completion(deletionError)
            }
            else {
                self.cache(feed, with: currentDate, OnCompletion: completion)
            }
        }
    }
    
    private func cache(_ feed: [FeedImage], with timestamp: Date, OnCompletion completion: @escaping (Error?) -> Void) {
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
    
            case let .found(feed: feed, timestamp: timestamp) where FeedCachePolicy.validate(timestamp, against: currentDate):
                completion(.success(feed.toModels()))
            
            case .found(_, _), .empty:
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
            
            case let .found(feed: _, timestamp: timestamp) where !FeedCachePolicy.validate(timestamp, against: currentDate):
                self.store.deleteFeedCache(completion: { _ in })
            
            case .found(feed: _, timestamp: _), .empty:
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
