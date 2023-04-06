//
//  ValidateCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 05/04/2023.
//

import XCTest
import EssentialFeed

class ValidateCacheUseCaseTests: XCTestCase {

    func test_init_doesNotPerformCacheValidation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_validateCache_requestsDeletionOfCacheWhenLoadingCacheRequestFails() {
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        
        store.completeLoad(withError: anyError())
        
        XCTAssertEqual(store.receivedMessages, [.loadImageFeed, .deleteCacheFeed])
    }
    
    func test_validateCache_requestsDeletionOfCacheOnExpiredCache() {
        let currentDate = Date()
        let (sut, store) = makeSUT({ currentDate })
        let expiredTimestamp = currentDate.minusFeedCacheMaxAge().addingSeconds(-1)
        
        sut.validateCache()
        
        store.completeLoad(with: uniqueImageFeeds().local, timestamp: expiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.loadImageFeed, .deleteCacheFeed])
    }
    
    func test_validateCache_requestsDeletionOfCacheOnCacheExpiration() {
        let currentDate = Date()
        let (sut, store) = makeSUT({ currentDate })
        let expiringTimestamp = currentDate.minusFeedCacheMaxAge().addingSeconds(-1)
        
        sut.validateCache()
        
        store.completeLoad(with: uniqueImageFeeds().local, timestamp: expiringTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.loadImageFeed, .deleteCacheFeed])
    }
    
    func test_validateCache_doesNotRequestsDeletionOfCacheOnNonExpiredCache() {
        let currentDate = Date()
        let (sut, store) = makeSUT({ currentDate })
        let nonExpiredTimestamp = currentDate.minusFeedCacheMaxAge().addingSeconds(1)
        
        sut.validateCache()
        
        store.completeLoad(with: uniqueImageFeeds().local, timestamp: nonExpiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.loadImageFeed])
    }
    
    func test_validateCache_doesNotRequestDeletionOfCacheWhenRetrievedCacheIsEmpty() {
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        
        store.completeLoadWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.loadImageFeed])
    }
    
    func test_validateCache_doesNotDeleteInvalidCacheAfterSUTInstanceHasBeenDeallocated(){
        let store = FeedStoreSpy()
        let timestamp = Date()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, timestamp: { timestamp })
        
        sut?.validateCache()
        
        sut = nil
        store.completeLoad(withError: anyError())
        
        XCTAssertEqual(store.receivedMessages, [.loadImageFeed])
    }
    
    //MARK: - Helpers
    
    private func makeSUT(_ timeStamp: () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (loader: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let loader = LocalFeedLoader(store: store, timestamp: timeStamp)
        trackMemoryLeak(store, file: file, line: line)
        trackMemoryLeak(loader, file: file, line: line)
        return (loader, store)
    }
}
