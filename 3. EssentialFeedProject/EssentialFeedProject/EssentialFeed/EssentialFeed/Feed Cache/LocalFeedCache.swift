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
        store.deleteFeedCache { [weak self] error in
            guard let self else { return }
            
            if error != nil {
                completion(error)
            }
            else {
                self.store.insertFeedCache(with: items, and: timestamp) { [weak self] error in
                    guard self != nil else { return }
                    completion(error)
                }
            }
        }
    }
}
