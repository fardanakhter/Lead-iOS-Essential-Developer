//
//  LocalFeedImageDataFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 21/05/2023.
//

import XCTest
import EssentialFeed

class LocalFeedImageDataFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotPerformLoadImageDataRequestOnCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestsImageData() {
        let (sut, store) = makeSUT()
        let imageURL = anyURL()
        
        let _ = sut.load(imageURL) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.load(dataForUrl: imageURL)])
    }
    
    func test_load_deliversErrorOnLoadImageDataFailure() {
        let (sut, store) = makeSUT()
        let retrievalError = anyError()
        
        expect(sut, toCompleteWith: .failure(failed()), when: {
            store.completeLoad(withError: retrievalError)
        })
    }
    
    func test_load_deliversNotFoundErrorWhenCacheIsEmpty() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(notFound()), when: {
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
        let (sut, _) = makeSUT()
        let imageURL = anyURL()
        
        var capturedResult = [LocalFeedImageDataLoader.LoadResult]()
        let task = sut.load(imageURL) { receivedResult in
            capturedResult.append(receivedResult)
        }
        task.cancel()
        
        XCTAssertTrue(capturedResult.isEmpty)
    }
    
    func test_load_doesNotInvokeCompletionAfterSUTInstanceIsDeallocated() {
        let store = FeedImageDataStoreSpy()
        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
        
        var capturedResult = [LocalFeedImageDataLoader.LoadResult]()
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
    
    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: LocalFeedImageDataLoader.LoadResult, when action: @escaping () -> Void, file: StaticString = #file, line: UInt = #line) {
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
    
    private func notFound() -> LocalFeedImageDataLoader.LoadError {
        return .notFound
    }
    
    private func failed() -> LocalFeedImageDataLoader.LoadError {
        return .unknown(anyError())
    }
    
}
