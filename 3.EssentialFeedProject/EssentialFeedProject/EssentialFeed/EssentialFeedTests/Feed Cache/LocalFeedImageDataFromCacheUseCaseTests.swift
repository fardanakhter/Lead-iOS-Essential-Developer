//
//  LocalFeedImageDataFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 21/05/2023.
//

import XCTest
import EssentialFeed

protocol FeedImageDataStoreTask {
    func cancel()
}

protocol FeedImageDataStore {
    typealias LoadResult = Result<Data?, Error>
    typealias LoadCompletion = (LoadResult) -> Void

    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func loadFeedImageDataCache(with url: URL, completion: @escaping LoadCompletion) -> FeedImageDataStoreTask
}

final class LocalFeedImageDataTaskWrapper: FeedImageDataLoaderTask {
    var wrapper: FeedImageDataStoreTask?
    
    private let completion: (LocalFeedImageDataLoader.Result) -> Void
    
    init(_ completion: @escaping (LocalFeedImageDataLoader.Result) -> Void) {
        self.completion = completion
    }
    
    func completeWith(_ result: LocalFeedImageDataLoader.Result) {
        self.completion(result)
    }
    
    func cancel() {
        wrapper?.cancel()
    }
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
    
    func load(_ url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask {
        let task = LocalFeedImageDataTaskWrapper(completion)
        task.wrapper = store.loadFeedImageDataCache(with: url) {[weak self] result in
            guard let self else { return }
            task.completeWith(result
                .mapError{ .unknown($0) }
                .flatMap { ($0?.isEmpty ?? true) ? .failure(.notFound) : .success($0!) }
            )
        }
        return task
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
        
        let _ = sut.load(imageURL) { _ in }
        
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
    
    func test_load_doesNotInvokeCompletionWhenCancelled() {
        let (sut, store) = makeSUT()
        let imageURL = anyURL()
        
        var capturedResult = [LocalFeedImageDataLoader.Result]()
        let task = sut.load(imageURL) { receivedResult in
            capturedResult.append(receivedResult)
        }
        task.cancel()
        
        XCTAssertTrue(capturedResult.isEmpty)
        XCTAssertEqual(store.cancelledURLs, [imageURL])
    }
    
    func test_load_doesNotInvokeCompletionAfterSUTInstanceIsDeallocated() {
        let store = FeedImageDataStoreSpy()
        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
        
        var capturedResult = [LocalFeedImageDataLoader.Result]()
        let _ = sut?.load(anyURL()) { receivedResult in
            capturedResult.append(receivedResult)
        }
        
        sut = nil
        store.completeLoadWithEmptyCache()
        
        XCTAssertTrue(capturedResult.isEmpty)
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

        let _ = sut.load(anyURL(), completion: { receivedResult in
            
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
        
        private struct Task: FeedImageDataStoreTask {
            private let callback: () -> Void
            
            init(callback: @escaping () -> Void) {
                self.callback = callback
            }
            
            func cancel() { callback() }
        }
        
        private var messages = [(url: URL, completion: LoadCompletion)]()
        
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        
        var cancelledURLs = [URL]()
        
        func loadFeedImageDataCache(with url: URL, completion: @escaping LoadCompletion) -> FeedImageDataStoreTask {
            messages.append((url, completion))
            return Task { [weak self] in
                self?.cancelledURLs.append(url)
            }
        }
        
        func completeLoad(withError error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func completeLoadWithEmptyCache(at index: Int = 0) {
            messages[index].completion(.success(nil))
        }
        
        func completeLoad(withCache data: Data, at index: Int = 0) {
            messages[index].completion(.success(data))
        }
        
    }
    
}
