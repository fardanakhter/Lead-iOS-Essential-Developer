//
//  LocalFeedImageDataFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 21/05/2023.
//

import XCTest

public protocol FeedImageDataStore {
    typealias LoadResult = Result<Data?, Error>
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
    
    enum Error: Swift.Error {
        case notFound
        case unknown(Swift.Error)
    }
    
    func load(_ url: URL, completion: @escaping (Result) -> Void) {
        store.loadFeedImageDataCache(with: url) { result in
            
            switch result {
            case let .success(data):
                if let cachedData = data, !cachedData.isEmpty {
                    completion(.success(cachedData))
                }
                else {
                    completion(.failure(.notFound))
                }
                
            case let .failure(error):
                completion(.failure(.unknown(error)))
            }
        }
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
    
    func test_load_deliversErrorOnLoadImageDataFailure() {
        let (sut, store) = makeSUT()
        let retrievalError = anyError()
        
        expect(sut, toCompleteWith: .failure(.unknown(retrievalError)), when: {
            store.completeLoad(withError: retrievalError)
        })
    }
    
    func test_load_deliversNotFoundErrorWhenCacheIsEmpty() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.notFound), when: {
            store.completeLoadWithEmptyCache()
        })
    }
    
    func test_load_deliversImageDataWhenCacheIsNonEmpty() {
        let (sut, store) = makeSUT()
        let imageData = anyData()
        
        expect(sut, toCompleteWith: .success(imageData), when: {
            store.completeLoad(withCache: imageData)
        })
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> (LocalFeedImageDataLoader, FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackMemoryLeak(store)
        trackMemoryLeak(sut)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: LocalFeedImageDataLoader.Result, when action: @escaping () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Waits for load completion")

        sut.load(anyURL(), completion: { receivedResult in
            
            switch (receivedResult, expectedResult) {
            case let (.success(receivedImages), .success(expectedImages)):
                XCTAssertEqual(receivedImages, expectedImages)
                
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError)
            
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        })
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private class FeedImageDataStoreSpy: FeedImageDataStore {
        private(set) var requestedURLs = [URL]()
        private var completions = [LoadCompletion]()
        
        func loadFeedImageDataCache(with url: URL, completion: @escaping LoadCompletion) {
            requestedURLs.append(url)
            completions.append(completion)
        }
        
        func completeLoad(withError error: Error, at index: Int = 0) {
            completions[index](.failure(error))
        }
        
        func completeLoadWithEmptyCache(at index: Int = 0) {
            completions[index](.success(nil))
        }
        
        func completeLoad(withCache data: Data, at index: Int = 0) {
            completions[index](.success(data))
        }
    }
}
