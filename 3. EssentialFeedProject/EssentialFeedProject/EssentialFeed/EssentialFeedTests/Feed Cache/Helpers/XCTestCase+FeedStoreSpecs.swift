//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 11/04/2023.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    
    // MARK: - Assertions
    
    func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toCompleteRetrievalWith: .success(.empty), file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toCompleteRetrievalTwiceWith: .success(.empty), file: file, line: line)
    }
    
    func assertThatRetrieveDeliversLastInsertedNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let feed = uniqueImageFeeds().local
        let timestamp = Date.init()
        
        insert((feed, timestamp), to: sut)
        
        expect(sut, toCompleteRetrievalWith: .success(.found(feed: feed, timestamp: timestamp)), file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let feed = uniqueImageFeeds().local
        let timestamp = Date.init()
        
        insert((feed, timestamp), to: sut)
        
        expect(sut, toCompleteRetrievalTwiceWith: .success(.found(feed: feed, timestamp: timestamp)), file: file, line: line)
    }
    
    func assertThatRetrieveDeliversErrorOnFailure(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toCompleteRetrievalWith: .failure(anyError()), file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectOnFailure(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toCompleteRetrievalTwiceWith: .failure(anyError()), file: file, line: line)
    }
    
    func assertThatInsertDoesNotDeliverErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let insertionError = insert((uniqueImageFeeds().local, Date()), to: sut)
        
        XCTAssertNil(insertionError, "Expected to insert cache successfully", file: file, line: line)
    }
    
    func assertThatInsertionDeliversErrorOnFailure(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let insertionError = insert((uniqueImageFeeds().local, Date()), to: sut)
        
        XCTAssertNotNil(insertionError, "Expected error in inserting cache", file: file, line: line)
    }
    
    func assertThatInsertionHasNoSideEffectOnFailure(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        insert((uniqueImageFeeds().local, Date()), to: sut)
        expect(sut, toCompleteRetrievalWith: .success(.empty), file: file, line: line)
    }
    
    func assertThatInsertionOverridesPreviouslyInsertedCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        insert((uniqueImageFeeds().local, Date()), to: sut)
        let secondCache = (feed: uniqueImageFeeds().local, timestamp: Date())
        insert(secondCache, to: sut)
        
        expect(sut, toCompleteRetrievalWith: .success(.found(feed: secondCache.feed, timestamp: secondCache.timestamp)), file: file, line: line)
    }
    
    func assertThatDeletionDoesNotDeliverErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let deletionError = delete(from: sut)
        
        XCTAssertNil(deletionError, "Expected to delete with no error", file: file, line: line)
    }
    
    func assertThatDeletionHasNoSideEffectWhenCacheIsEmpty(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        delete(from: sut)
        expect(sut, toCompleteRetrievalWith: .success(.empty), file: file, line: line)
    }
    
    func assertThatDeletionDoesNotDeliverErrorWhenCacheIsNonEmpty(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        insert((uniqueImageFeeds().local, Date()), to: sut)
        let deletionError = delete(from: sut)
        
        XCTAssertNil(deletionError, "Expected to delete cache successfully", file: file, line: line)
    }
    
    func assertThatDeletionEmptiesPreviouslyInsertedCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        insert((uniqueImageFeeds().local, Date()), to: sut)
        delete(from: sut)
        
        expect(sut, toCompleteRetrievalWith: .success(.empty), file: file, line: line)
    }
    
    func assertThatDeletionDeliversErrorOnFailure(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let deletionError = delete(from: sut)
        
        XCTAssertNotNil(deletionError, "Expected to delete with error", file: file, line: line)
    }
    
    func assertThatDeletionHasNoSideEffectOnFailure(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        delete(from: sut)

        expect(sut, toCompleteRetrievalWith: .success(.empty), file: file, line: line)
    }
    
    func assertThatSideEffectsRunsSerially(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
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
        XCTAssertEqual(completedOperationsInOrder, [operation1, operation2, operation3],
                       "Expected side-effects to run serially but operations completed in wrong order", file: file , line: line)
    }
    
    // MARK: - Expectations
    
    func expect(_ sut: FeedStore, toCompleteRetrievalTwiceWith expectedResult: LoadFeedCacheResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toCompleteRetrievalWith: expectedResult, file: file, line: line)
        expect(sut, toCompleteRetrievalWith: expectedResult, file: file, line: line)
    }
    
    func expect(_ sut: FeedStore, toCompleteRetrievalWith expectedResult: LoadFeedCacheResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Waits for loadFeedCache completion")

        sut.loadFeedCache { result in
            switch (result, expectedResult) {
            case (.success(.empty), .success(.empty)), (.failure, .failure):
                break
                
            case let (.success(.found(feed, timestamp)), .success(.found(expectedFeed, expectedTimestamp))):
                XCTAssertEqual(feed, expectedFeed)
                XCTAssertEqual(timestamp, expectedTimestamp)
                
            default:
                XCTFail("Expected \(expectedResult), got \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Commands
    
    @discardableResult
    func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
        let exp = expectation(description: "Waits for loadFeedCache completion")
        
        var receivedError: Error?
        sut.insertFeedCache(with: cache.feed, and: cache.timestamp) { error in
            receivedError = error
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
    
    @discardableResult
    func delete(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "Waits for delete completion")
        var deletionError: Error?
        sut.deleteFeedCache { error in
            deletionError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 3.0)
        return deletionError
    }
    
}
