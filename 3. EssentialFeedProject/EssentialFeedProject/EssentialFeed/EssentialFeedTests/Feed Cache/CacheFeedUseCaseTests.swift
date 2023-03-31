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
    
    func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteFeedCache { error in
            completion(error)
        }
    }
}

class FeedStore {
    private(set) var deleteFeedCacheCallCount: UInt = 0
    private(set) var insertFeedItemsCallCount: UInt = 0
    
    typealias DeleteCompletion = (Error?) -> Void
    
    private var completionsForDeletion = [DeleteCompletion]()
    
    func deleteFeedCache(completion: @escaping DeleteCompletion) {
        deleteFeedCacheCallCount += 1
        completionsForDeletion.append(completion)
    }
    
    func completeDeletion(withError error: NSError, at index: Int = 0) {
        completionsForDeletion[index](error)
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
        
        loader.save(feedItems) { _ in }
        
        XCTAssertEqual(store.deleteFeedCacheCallCount, 1)
    }
    
    func test_save_doesNotRequestsInsertionOnCacheDeletionError() {
        let store = FeedStore()
        let loader = LocalFeedLoader(store: store)
        let feedItems = [uniqueItem(), uniqueItem()]
        let deleteError = anyError()
        let exp = expectation(description: "Waits for completion!")
        
        var receivedError: Error?
        loader.save(feedItems) { error in
            receivedError = error
            exp.fulfill()
        }
        
        store.completeDeletion(withError: deleteError)
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as? NSError, deleteError)
        XCTAssertEqual(store.insertFeedItemsCallCount, 0)
    }
    
    
    
    //MARK: - Helpers
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: nil, location: nil, imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
    
    private func anyError() -> NSError {
        NSError(domain: "Test", code: 0)
    }

}
