//
//  CacheFeedImageDataUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 22/05/2023.
//

import XCTest
import EssentialFeed

class CacheFeedImageDataUseCaseTests: XCTestCase {

    func test_init_doesNotPerformRetrievalOnCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_failsToInsertNewCacheFeed() {
        let (sut, store) = makeSUT()
        let insertError = anyError()
        
        expect(sut, toCompleteWith: failed(), when: {
            store.completeInsertion(withError: insertError)
        })
    }
    
    func test_save_succeedsToInsertNewCacheFeed() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: success(), when: {
            store.completeInsertionSuccessfully()
        })
    }
    
    func test_save_doesNotInvokeCompletionAfterSutInstanceIsDeallocated() {
        let timeStamp = Date()
        let store = FeedImageDataStoreSpy()
        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
        
        var capturedResult = [LocalFeedImageDataLoader.SaveResult]()
        sut?.save(anyData(), with: anyURL()) { receivedResult in
            capturedResult.append(receivedResult)
        }
        
        sut = nil
        store.completeInsertion(withError: anyError())
        store.completeInsertionSuccessfully()
        
        XCTAssertTrue(capturedResult.isEmpty)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (loader: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let loader = LocalFeedImageDataLoader(store: store)
        trackMemoryLeak(store, file: file, line: line)
        trackMemoryLeak(loader, file: file, line: line)
        return (loader, store)
    }

    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: LocalFeedImageDataLoader.SaveResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.save(anyData(), with: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success, .success):
                break
                
            case (.failure(let receivedError as LocalFeedImageDataLoader.SaveError),
                  .failure(let expectedError as LocalFeedImageDataLoader.SaveError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func failed() -> LocalFeedImageDataLoader.SaveResult {
        return .failure(LocalFeedImageDataLoader.SaveError.failed)
    }
    
    private func success() -> LocalFeedImageDataLoader.SaveResult {
        return .success(())
    }
}
