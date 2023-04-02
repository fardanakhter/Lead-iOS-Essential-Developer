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
    
    public init(store: FeedStore, timestamp: () -> Date) {
        self.store = store
        self.timestamp = timestamp()
    }
    
    public func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteFeedCache { [weak self] error in
            guard let self else { return }
            
            if let deletionError = error {
                completion(deletionError)
            }
            else {
                self.cache(items, with: timestamp, OnCompletion: completion)
            }
        }
    }
    
    private func cache(_ items: [FeedItem], with timestamp: Date, OnCompletion completion: @escaping (Error?) -> Void) {
        self.store.insertFeedCache(with: items.toLocalFeed(), and: timestamp) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

extension Array where Element == FeedItem {
    func toLocalFeed() -> [LocalFeedItem] {
        self.map{ LocalFeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL) }
    }
}
