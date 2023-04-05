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
    
    //MARK: - Helpers
    
    private func makeSUT(_ timeStamp: () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (loader: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let loader = LocalFeedLoader(store: store, timestamp: timeStamp)
        trackMemoryLeak(store, file: file, line: line)
        trackMemoryLeak(loader, file: file, line: line)
        return (loader, store)
    }
}
