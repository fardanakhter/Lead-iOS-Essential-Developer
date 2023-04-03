//
//  LocalFeedCache.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 01/04/2023.
//

import Foundation

public class LocalFeedLoader {
    private let store: FeedStore
    private let timestamp: Date
    
    public typealias SaveResult = Error?
    public typealias LoadResult = LoadFeedResult
    
    public init(store: FeedStore, timestamp: () -> Date) {
        self.store = store
        self.timestamp = timestamp()
    }
    
    public func save(_ feed: [FeedImage], completion: @escaping (Error?) -> Void) {
        store.deleteFeedCache { [weak self] error in
            guard let self else { return }
            
            if let deletionError = error {
                completion(deletionError)
            }
            else {
                self.cache(feed, with: timestamp, OnCompletion: completion)
            }
        }
    }
    
    private func cache(_ feed: [FeedImage], with timestamp: Date, OnCompletion completion: @escaping (Error?) -> Void) {
        self.store.insertFeedCache(with: feed.toLocalFeed(), and: timestamp) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        self.store.loadFeedCache { error in
            if let error {
                completion(.failure(error))
            }
        }
    }
}

extension Array where Element == FeedImage {
    func toLocalFeed() -> [LocalFeedImage] {
        self.map{ LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}
