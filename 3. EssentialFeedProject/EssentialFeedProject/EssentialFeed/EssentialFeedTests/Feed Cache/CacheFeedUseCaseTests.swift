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
    private let timestamp: Date
    
    init(store: FeedStore, timestamp: () -> Date) {
        self.store = store
        self.timestamp = timestamp()
    }
    
    func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteFeedCache { [unowned self] error in
            guard error == nil else {
                completion(error)
                return
            }
            self.store.insertFeedCache(with: items, and: timestamp, completion: completion)
        }
    }
}

class FeedStore {
    
    typealias DeleteCompletion = (Error?) -> Void
    typealias InsertCompletion = (Error?) -> Void
    
    enum ReceivedMessages: Equatable {
        case deleteCacheFeed
        case insertCacheFeed([FeedItem], Date)
    }
    
    private var completionsForDeletion = [DeleteCompletion]()
    private var completionsForInsertion = [InsertCompletion]()
    
    private(set) var receivedMessages = [ReceivedMessages]()
    
    func deleteFeedCache(completion: @escaping DeleteCompletion) {
        completionsForDeletion.append(completion)
        receivedMessages.append(.deleteCacheFeed)
    }
    
    func completeDeletion(withError error: NSError, at index: Int = 0) {
        completionsForDeletion[index](error)
    }
    
    func completeDeletionWithSuccess(at index: Int = 0) {
        completionsForDeletion[index](nil)
    }
    
    func insertFeedCache(with items: [FeedItem], and timestamp: Date, completion: @escaping InsertCompletion) {
        completionsForInsertion.append(completion)
        receivedMessages.append(.insertCacheFeed(items, timestamp))
    }
    
    func completeInsertion(withError error: NSError, at index: Int = 0) {
        completionsForDeletion[index](error)
    }
    
    func completeInsertionWithSuccess(at index: Int = 0) {
        completionsForInsertion[index](nil)
    }
    
}

// Test Code
class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotPerformDeletionOnCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let feedItems = [uniqueItem(), uniqueItem()]
        
        sut.save(feedItems) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_save_doesNotRequestsInsertionOnCacheDeletionError() {
        let (sut, store) = makeSUT()
        let feedItems = [uniqueItem(), uniqueItem()]
        
        sut.save(feedItems) { _ in }
        store.completeDeletion(withError: anyError())
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_save_requestsNewCacheInsertionOnSuccessfulCacheDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT({ timestamp })
        let feedItems = [uniqueItem(), uniqueItem()]

        sut.save(feedItems) { _ in }
        store.completeDeletionWithSuccess()

        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed, .insertCacheFeed(feedItems, timestamp)])
    }
    
    func test_save_requestsNewCacheInsertionWithTimeStampOnSuccessfulCacheDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT({ timestamp })
        let feedItems = [uniqueItem(), uniqueItem()]
        
        sut.save(feedItems) { _ in }

        store.completeDeletionWithSuccess()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed, .insertCacheFeed(feedItems, timestamp)])
    }
    
    func test_save_failsToDeleteCacheFeed() {
        let (sut, store) = makeSUT()
        let deleteError = anyError()
        
        expect(sut, toCompleteWithError: deleteError, when: {
            store.completeDeletion(withError: deleteError)
        })
    }
    
    func test_save_failsToInsertNewCacheFeed() {
        let (sut, store) = makeSUT()
        let insertError = anyError()
        
        expect(sut, toCompleteWithError: insertError, when: {
            store.completeDeletionWithSuccess()
            store.completeInsertion(withError: insertError)
        })
    }
    
    func test_save_succeedsToInsertNewCacheFeed() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWithError: nil, when: {
            store.completeDeletionWithSuccess()
            store.completeInsertionWithSuccess()
        })
    }
    
    //MARK: - Helpers
    
    private func makeSUT(_ timeStamp: () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (loader: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let loader = LocalFeedLoader(store: store, timestamp: timeStamp)
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

    private func expect(_ sut: LocalFeedLoader, toCompleteWithError error: NSError?, when action: @escaping () -> Void) {
        let feedItems = [uniqueItem(), uniqueItem()]
        let exp = expectation(description: "Waits for save completion!")
        
        var receivedErrors = [Error?]()
        sut.save(feedItems) { error in
            receivedErrors.append(error)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedErrors as [NSError?], [error])
    }
    
}
