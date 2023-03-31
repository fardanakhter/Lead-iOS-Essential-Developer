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
        store.deleteFeedCache { [unowned self] error in
            if error == nil {
                self.store.insertFeedCache(with: items)
            }
            else {
                completion(error)
            }
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
    
    func completeDeletionWithSuccess(at index: Int = 0) {
        completionsForDeletion[index](nil)
    }
    
    func insertFeedCache(with: [FeedItem]) {
        insertFeedItemsCallCount += 1
    }
    
}

// Test Code
class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotPerformDeletionOnCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.deleteFeedCacheCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let feedItems = [uniqueItem(), uniqueItem()]
        
        sut.save(feedItems) { _ in }
        
        XCTAssertEqual(store.deleteFeedCacheCallCount, 1)
    }
    
    func test_save_doesNotRequestsInsertionOnCacheDeletionError() {
        let (sut, store) = makeSUT()
        let feedItems = [uniqueItem(), uniqueItem()]
        let deleteError = anyError()
        let exp = expectation(description: "Waits for completion!")
        
        var receivedError: Error?
        sut.save(feedItems) { error in
            receivedError = error
            exp.fulfill()
        }
        
        store.completeDeletion(withError: deleteError)
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as? NSError, deleteError)
        XCTAssertEqual(store.insertFeedItemsCallCount, 0)
    }
    
    func test_save_requestsNewCacheInsertionOnSuccessfulCacheDeletion() {
        let (sut, store) = makeSUT()
        let feedItems = [uniqueItem(), uniqueItem()]

        sut.save(feedItems) { _ in }

        store.completeDeletionWithSuccess()

        XCTAssertEqual(store.insertFeedItemsCallCount, 1)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (LocalFeedLoader, FeedStore) {
        let store = FeedStore()
        let loader = LocalFeedLoader(store: store)
        trackMemoryLeak(store, file: file, line: line)
        trackMemoryLeak(loader, file: file, line: line)
        return (loader, store)
    }
    
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
