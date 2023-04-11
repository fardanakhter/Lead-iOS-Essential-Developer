//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 11/04/2023.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {

    func expect(_ sut: FeedStore, toCompleteRetrievalTwiceWith expectedResult: LoadFeedCacheResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toCompleteRetrievalWith: expectedResult)
        expect(sut, toCompleteRetrievalWith: expectedResult)
    }
    
    func expect(_ sut: FeedStore, toCompleteRetrievalWith expectedResult: LoadFeedCacheResult, file: StaticString = #file, line: UInt = #line) {
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
    func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore, file: StaticString = #file, line: UInt = #line) -> Error? {
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
