//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 08/04/2023.
//

import XCTest
import EssentialFeed

final class CodableFeedStoreTests: XCTestCase {

    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }
    
    func test_loadFeedCache_returnsEmptyResultOnRetrievingEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toCompleteRetrievalWith: .empty)
    }
    
    func test_loadFeedCache_hasNoSideEffectWhenRetrivingEmptyCacheTwice() {
        let sut = makeSUT()

        expect(sut, toCompleteRetrievalTwiceWith: .empty)
    }
    
    func test_loadFeedCache_deliversLastInsertedCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeeds().local
        let timestamp = Date.init()
        
        let insertionError = insert((feed, timestamp), to: sut)
        XCTAssertNil(insertionError, "Expected to insert cache successfully")
        expect(sut, toCompleteRetrievalWith: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_loadFeedCache_hasNoSideEffectWhenRetrievingNonEmptyCacheTwice() {
        let sut = makeSUT()
        let feed = uniqueImageFeeds().local
        let timestamp = Date.init()
        
        let insertionError = insert((feed, timestamp), to: sut)
        XCTAssertNil(insertionError, "Expected to insert cache successfully")
        expect(sut, toCompleteRetrievalTwiceWith: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_loadFeedCache_deliversErrorWhenRetrievingCacheFails() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toCompleteRetrievalWith: .failure(anyError()))
    }
    
    func test_loadFeedCache_hasNoSideEffectWhenRetrievingCacheFailsTwice() {
        let sut = makeSUT()
        
        try! "invalid data".write(to: testSpecificStoreURL(), atomically: false, encoding: .utf8)
        
        expect(sut, toCompleteRetrievalWith: .failure(anyError()))
    }
    
    func test_insertFeedCache_overridesLastCacheWithLatestCache() {
        let sut = makeSUT()
        
        let firstCache = (feed: uniqueImageFeeds().local, timestamp: Date())
        let firstInsertionError = insert(firstCache, to: sut)
        XCTAssertNil(firstInsertionError, "Expected to insert cache successfully")
        
        let secondCache = (feed: uniqueImageFeeds().local, timestamp: Date())
        let secondInsertionError = insert(secondCache, to: sut)
        XCTAssertNil(secondInsertionError, "Expected to override cache successfully")
        
        expect(sut, toCompleteRetrievalWith: .found(feed: secondCache.feed, timestamp: secondCache.timestamp))
    }
    
    func test_insertFeedCache_deliversErrorWhenCacheInsertionFails() {
        let invalidStoreURL = anyInvalidURL()
        let sut = makeSUT(invalidStoreURL)
        
        let insertionError: Error?
        insertionError = insert((uniqueImageFeeds().local, Date()), to: sut)
        XCTAssertNotNil(insertionError, "Expected error in inserting cache")
    }
    
    func test_deleteFeedCache_doesNotDeleteEmptyCacheAndResultsInNoError() {
        let sut = makeSUT()

        let deletionError = delete(from: sut)
        XCTAssertNil(deletionError, "Expected to delete with no error")
        
        expect(sut, toCompleteRetrievalWith: .empty)
    }
    
    func test_deleteFeedCache_deletesNonEmptyCacheAndLeavesCacheEmpty() {
        let sut = makeSUT()
        
        insert((uniqueImageFeeds().local, Date()), to: sut)
        let deletionError = delete(from: sut)
        XCTAssertNil(deletionError, "Expected to delete cache successfully")
        
        expect(sut, toCompleteRetrievalWith: .empty)
    }
    
    func test_deleteFeedCache_deliversErrorWhenCacheDeletionFails() {
        let nonPermissableDirectory = noDeleteAccessDirectory()
        let sut = makeSUT(nonPermissableDirectory)

        let deletionError = delete(from: sut)

        XCTAssertNotNil(deletionError, "Expected to delete with error")
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        
        var completedOperationsInOrder = [XCTestExpectation]()
        let operation1 = expectation(description: "Operation 1")
        sut.insertFeedCache(with: uniqueImageFeeds().local, and: Date()) { _ in
            completedOperationsInOrder.append(operation1)
            operation1.fulfill()
        }
        
        let operation2 = expectation(description: "Operation 2")
        sut.deleteFeedCache { _ in
            completedOperationsInOrder.append(operation2)
            operation2.fulfill()
        }
        
        let operation3 = expectation(description: "Operation 3")
        sut.insertFeedCache(with: uniqueImageFeeds().local, and: Date()) { _ in
            completedOperationsInOrder.append(operation3)
            operation3.fulfill()
        }
        
        wait(for: [operation1, operation2, operation3], timeout: 1.0)
        XCTAssertEqual(completedOperationsInOrder, [operation1, operation2, operation3], "Expected side-effectst to run serially but operations completed in wrong order")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(_ storeURL: URL? = nil) -> FeedStore {
        let sut = CodableFeedStore(storeURL ?? testSpecificStoreURL())
        trackMemoryLeak(sut)
        return sut
    }
    
    private func expect(_ sut: FeedStore, toCompleteRetrievalTwiceWith expectedResult: LoadFeedCacheResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toCompleteRetrievalWith: expectedResult)
        expect(sut, toCompleteRetrievalWith: expectedResult)
    }
    
    private func expect(_ sut: FeedStore, toCompleteRetrievalWith expectedResult: LoadFeedCacheResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Waits for loadFeedCache completion")

        sut.loadFeedCache { result in
            switch (result, expectedResult) {
            case (.empty, .empty), (.failure, .failure):
                break
                
            case let (.found(feed, timestamp), .found(expectedFeed, expectedTimestamp)):
                XCTAssertEqual(feed, expectedFeed)
                XCTAssertEqual(timestamp, expectedTimestamp)
                
            default:
                XCTFail("Expected \(expectedResult), got \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    @discardableResult
    private func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore, file: StaticString = #file, line: UInt = #line) -> Error? {
        let exp = expectation(description: "Waits for loadFeedCache completion")
        
        var receivedError: Error?
        sut.insertFeedCache(with: cache.feed, and: cache.timestamp) { error in
            receivedError = error
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
    
    private func delete(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "Waits for delete completion")
        var deletionError: Error?
        sut.deleteFeedCache { error in
            deletionError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 3.0)
        return deletionError
    }
    
    private func testSpecificStoreURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathExtension("\(type(of: self)).store")
    }
    
    private func noDeleteAccessDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func anyInvalidURL() -> URL {
        URL(string: "invalid://store-url")!
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    
}
