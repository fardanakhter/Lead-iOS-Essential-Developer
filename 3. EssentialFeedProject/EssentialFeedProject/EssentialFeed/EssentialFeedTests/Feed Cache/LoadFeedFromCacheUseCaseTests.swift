//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 03/04/2023.
//

import XCTest
import EssentialFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotPerformLoadImageFeedRequestOnCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestsImageFeed() {
        let (sut, store) = makeSUT()
        
        sut.load() { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.loadImageFeed])
    }
    
    func test_load_deliversErrorOnLoadImageFeedFailure() {
        let (sut, store) = makeSUT()
        let loadFeedError = anyError()
        let exp = expectation(description: "Waits for load completion")
        
        var receivedResult = [Error?]()
        sut.load() { result in
            switch result {
            case .failure(let error):
                receivedResult.append(error)
            default:
                XCTFail("Expected failure, got \(result) instead")
            }
            exp.fulfill()
        }
        
        store.completeLoad(withError: loadFeedError)
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedResult as [NSError?], [loadFeedError])
    }
    
    //MARK: - Helpers
    
    private func makeSUT(_ timeStamp: () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (loader: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let loader = LocalFeedLoader(store: store, timestamp: timeStamp)
        trackMemoryLeak(store, file: file, line: line)
        trackMemoryLeak(loader, file: file, line: line)
        return (loader, store)
    }
    
    private func anyError() -> NSError {
        NSError(domain: "Test", code: 0)
    }
}
