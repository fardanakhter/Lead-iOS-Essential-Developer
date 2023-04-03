//
//  CacheFeedUseCaseTest.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 31/03/2023.
//

import XCTest
import EssentialFeed

class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotPerformDeletionOnCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let images = [uniqueImage(), uniqueImage()]
        
        sut.save(images) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_save_doesNotRequestsInsertionOnCacheDeletionError() {
        let (sut, store) = makeSUT()
        let images = [uniqueImage(), uniqueImage()]
        
        sut.save(images) { _ in }
        store.completeDeletion(withError: anyError())
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_save_requestsNewCacheInsertionOnSuccessfulCacheDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT({ timestamp })
        let feed = uniqueImageFeeds()

        sut.save(feed.models) { _ in }
        store.completeDeletionWithSuccess()

        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed, .insertCacheFeed(feed.local, timestamp)])
    }
    
    func test_save_requestsNewCacheInsertionWithTimeStampOnSuccessfulCacheDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT({ timestamp })
        let feed = uniqueImageFeeds()
        
        sut.save(feed.models) { _ in }

        store.completeDeletionWithSuccess()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed, .insertCacheFeed(feed.local, timestamp)])
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
    
    func test_save_doesNotDeliverDeletionErrorAfterSutInstanceIsDeallocated() {
        let timeStamp = Date()
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, timestamp: { timeStamp })
        
        var receivedResult = [LocalFeedLoader.SaveResult]()
        sut?.save([uniqueImage()]) { error in
            receivedResult.append(error)
        }
        
        sut = nil
        store.completeDeletion(withError: anyError())
        
        XCTAssertTrue(receivedResult.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSutInstanceIsDeallocated() {
        let timeStamp = Date()
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, timestamp: { timeStamp })
        
        var receivedResult = [LocalFeedLoader.SaveResult]()
        sut?.save([uniqueImage()]) { error in
            receivedResult.append(error)
        }
        
        store.completeDeletionWithSuccess()
        sut = nil
        store.completeInsertion(withError: anyError())
        
        XCTAssertTrue(receivedResult.isEmpty)
    }
    
    func test_save_doesNotInvokeCompletionOnSuccessfulInsertionAfterSutInstanceIsDeallocated() {
        let timeStamp = Date()
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, timestamp: { timeStamp })
        
        var receivedResult = [LocalFeedLoader.SaveResult]()
        sut?.save([uniqueImage()]) { error in
            receivedResult.append(error)
        }
        
        store.completeDeletionWithSuccess()
        sut = nil
        store.completeInsertionWithSuccess()
        
        XCTAssertTrue(receivedResult.isEmpty)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(_ timeStamp: () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (loader: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let loader = LocalFeedLoader(store: store, timestamp: timeStamp)
        trackMemoryLeak(store, file: file, line: line)
        trackMemoryLeak(loader, file: file, line: line)
        return (loader, store)
    }
    
    private func uniqueImage() -> FeedImage {
        return FeedImage(id: UUID(), description: nil, location: nil, url: anyURL())
    }
    
    private func uniqueImageFeeds() -> (models: [FeedImage], local: [LocalFeedImage]) {
        let feeds = [uniqueImage(), uniqueImage()]
        let localFeeds = feeds.map {
            LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
        }
        return (feeds, localFeeds)
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
    
    private func anyError() -> NSError {
        NSError(domain: "Test", code: 0)
    }

    private func expect(_ sut: LocalFeedLoader, toCompleteWithError error: NSError?, when action: @escaping () -> Void) {
        let feeds = [uniqueImage(), uniqueImage()]
        let exp = expectation(description: "Waits for save completion!")
        
        var receivedErrors = [Error?]()
        sut.save(feeds) { error in
            receivedErrors.append(error)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedErrors as [NSError?], [error])
    }
    
    class FeedStoreSpy: FeedStore {
        
        enum ReceivedMessages: Equatable {
            case deleteCacheFeed
            case insertCacheFeed([LocalFeedImage], Date)
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
        
        func insertFeedCache(with feed: [LocalFeedImage], and timestamp: Date, completion: @escaping InsertCompletion) {
            completionsForInsertion.append(completion)
            receivedMessages.append(.insertCacheFeed(feed, timestamp))
        }
        
        func completeInsertion(withError error: NSError, at index: Int = 0) {
            completionsForInsertion[index](error)
        }
        
        func completeInsertionWithSuccess(at index: Int = 0) {
            completionsForInsertion[index](nil)
        }
        
    }
    
}
