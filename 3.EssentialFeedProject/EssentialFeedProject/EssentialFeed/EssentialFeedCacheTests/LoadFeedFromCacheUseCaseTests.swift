//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 03/04/2023.
//

import XCTest
import EssentialFeedCache

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
        let retrievalError = anyError()
        
        expect(sut, toCompleteWith: .failure(retrievalError), when: {
            store.completeLoad(withError: retrievalError)
        })
    }
    
    func test_load_deliversNoFeedImagesOnRetrievingEmptyCache() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success([]), when: {
            store.completeLoadWithEmptyCache()
        })
    }
    
    func test_load_deliversFeedImagesOnNonExpiredCache() {
        let currentDate = Date()
        let (sut, store) = makeSUT({ currentDate })
        let imageFeeds = uniqueImageFeeds()
        
        expect(sut, toCompleteWith: .success(imageFeeds.models), when: {
            let nonExpiredTimestamp = currentDate.minusFeedCacheMaxAge().addingSeconds(1)
            store.completeLoad(with: imageFeeds.local, timestamp: nonExpiredTimestamp)
        })
    }
    
    func test_load_deliversNoFeedImageOnExpiredCache() {
        let currentDate = Date()
        let (sut, store) = makeSUT({ currentDate })
        let imageFeeds = uniqueImageFeeds()
        
        expect(sut, toCompleteWith: .success([]), when: {
            let expiredTimestamp = currentDate.minusFeedCacheMaxAge().addingSeconds(-1)
            store.completeLoad(with: imageFeeds.local, timestamp: expiredTimestamp)
        })
    }
    
    func test_load_deliversNoFeedImageOnCacheExpiration() {
        let currentDate = Date()
        let (sut, store) = makeSUT({ currentDate })
        let imageFeeds = uniqueImageFeeds()
        
        expect(sut, toCompleteWith: .success([]), when: {
            let expiringTimestamp = currentDate.minusFeedCacheMaxAge()
            store.completeLoad(with: imageFeeds.local, timestamp: expiringTimestamp)
        })
    }
    
    func test_load_hasNoSideEffectOnNonExpiredCache() {
        let currentDate = Date()
        let (sut, store) = makeSUT({ currentDate })
        let nonExpiredCache = currentDate.minusFeedCacheMaxAge().addingSeconds(1)
        
        sut.load { _ in }
        
        store.completeLoad(with: uniqueImageFeeds().local, timestamp: nonExpiredCache)
        
        XCTAssertEqual(store.receivedMessages, [.loadImageFeed])
    }
    
    func test_load_hasNoSideEffectOnExpiredCache() {
        let currentDate = Date()
        let (sut, store) = makeSUT({ currentDate })
        let expiredTimestamp = currentDate.minusFeedCacheMaxAge().addingSeconds(-1)
        
        sut.load { _ in }
        
        store.completeLoad(with: uniqueImageFeeds().local, timestamp: expiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.loadImageFeed])
    }
    
    func test_load_hasNoSideEffectOnCacheExpiration() {
        let currentDate = Date()
        let (sut, store) = makeSUT({ currentDate })
        let expiringTimestamp = currentDate.minusFeedCacheMaxAge().addingSeconds(-1)
        
        sut.load { _ in }
        
        store.completeLoad(with: uniqueImageFeeds().local, timestamp: expiringTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.loadImageFeed])
    }
    
    func test_load_hasNoSideEffectWhenLoadingCacheRequestFails() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        
        store.completeLoad(withError: anyError())
        
        XCTAssertEqual(store.receivedMessages, [.loadImageFeed])
    }
    
    func test_load_hasNoSideEffectWhenRetrievedCacheIsEmpty() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        
        store.completeLoadWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.loadImageFeed])
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceIsDeallocated() {
        let store = FeedStoreSpy()
        let timestamp = Date()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, timestamp: { timestamp })
        
        var receivedResult = [LocalFeedLoader.LoadResult]()
        sut?.load { result in
            receivedResult.append(result)
        }
        
        sut = nil
        store.completeLoadWithEmptyCache()
        
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
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.LoadResult, when action: @escaping () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Waits for load completion")

        sut.load { receivedResult in
            
            switch (receivedResult, expectedResult) {
            case let (.success(receivedImages), .success(expectedImages)):
                XCTAssertEqual(receivedImages, expectedImages)
                
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError)
            
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }

}

