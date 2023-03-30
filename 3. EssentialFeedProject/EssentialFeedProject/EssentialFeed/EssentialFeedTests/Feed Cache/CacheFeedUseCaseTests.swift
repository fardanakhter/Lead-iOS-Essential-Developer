//
//  CacheFeedUseCaseTest.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 31/03/2023.
//

import XCTest
import EssentialFeed

//Production Code
class LocalFeedLoader {
    private let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteFeedCache()
    }
}

class FeedStore {
    private(set) var deleteFeedCacheCallCount: UInt = 0
    
    func deleteFeedCache() {
        deleteFeedCacheCallCount += 1
    }
}

// Test Code
class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotPerformDeletionOnCreation() {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteFeedCacheCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let store = FeedStore()
        let loader = LocalFeedLoader(store: store)
        let feedItems = [uniqueItem(), uniqueItem()]
        
        loader.save(feedItems)
        
        XCTAssertEqual(store.deleteFeedCacheCallCount, 1)
    }
    
    //MARK: - Helpers
    
    func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: nil, location: nil, imageURL: anyURL())
    }
    
    func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }

}
