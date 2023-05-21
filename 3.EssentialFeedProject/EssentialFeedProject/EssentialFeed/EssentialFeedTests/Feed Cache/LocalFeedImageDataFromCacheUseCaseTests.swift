//
//  LocalFeedImageDataFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 21/05/2023.
//

import XCTest

public protocol FeedImageDataStore {
    typealias CachedFeedImageData = (data: Data, timestamp: Date)
    typealias LoadResult = Result<CachedFeedImageData?, Error>
    typealias LoadCompletion = (LoadResult) -> Void

    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func loadFeedImageDataCache(with url: URL, completion: @escaping LoadCompletion)
}

final class LocalFeedImageDataLoader {
    private let store: FeedImageDataStore
    
    init(store: FeedImageDataStore) {
        self.store = store
    }
    
    typealias Result = Swift.Result<Data,Error>
    
    func load(_ url: URL, completion: @escaping (Result) -> Void) {
        store.loadFeedImageDataCache(with: url) { _ in }
    }
}

class LocalFeedImageDataFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotPerformLoadImageDataRequestOnCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.requestedURLs, [])
    }
    
    func test_load_requestsImageData() {
        let (sut, store) = makeSUT()
        let imageURL = anyURL()
        
        sut.load(imageURL) { _ in }
        
        XCTAssertEqual(store.requestedURLs, [imageURL])
    }
    
    private func makeSUT() -> (LocalFeedImageDataLoader, FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackMemoryLeak(store)
        trackMemoryLeak(sut)
        return (sut, store)
    }
    
    private class FeedImageDataStoreSpy: FeedImageDataStore {
        private(set) var requestedURLs = [URL]()
        
        func loadFeedImageDataCache(with url: URL, completion: @escaping LoadCompletion) {
            requestedURLs.append(url)
        }
    }
}
