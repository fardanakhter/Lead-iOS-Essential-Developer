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
    
    public init(store: FeedStore, timestamp: () -> Date) {
        self.store = store
        self.timestamp = timestamp()
    }
    
    public func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteFeedCache { [unowned self] error in
            guard error == nil else {
                completion(error)
                return
            }
            self.store.insertFeedCache(with: items, and: timestamp, completion: completion)
        }
    }
}
