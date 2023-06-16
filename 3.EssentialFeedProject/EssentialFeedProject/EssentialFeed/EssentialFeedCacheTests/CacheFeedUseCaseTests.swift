//
//  CacheFeedUseCaseTest.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 31/03/2023.
//

import XCTest
import EssentialFeedCache

class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotPerformDeletionOnCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let images = [uniqueImage(), uniqueImage()]
        
        sut.save(images) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_save_doesNotRequestsInsertionOnCacheDeletionError() {
        let (sut, store) = makeSUT()
        let images = [uniqueImage(), uniqueImage()]
        
        sut.save(images) { _ in }
        store.completeDeletion(withError: anyError())
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_save_requestsNewCacheInsertionOnSuccessfulCacheDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT({ timestamp })
        let feed = uniqueImageFeeds()

        sut.save(feed.models) { _ in }
        store.completeDeletionWithSuccess()

        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed, .insertCacheFeed(feed.local, timestamp)])
    }
    
    func test_save_requestsNewCacheInsertionWithTimeStampOnSuccessfulCacheDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT({ timestamp })
        let feed = uniqueImageFeeds()
        
        sut.save(feed.models) { _ in }

        store.completeDeletionWithSuccess()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed, .insertCacheFeed(feed.local, timestamp)])
    }
    
    func test_save_failsToDeleteCacheFeed() {
        let (sut, store) = makeSUT()
        let deleteError = anyError()
        
        expect(sut, toCompleteSaveWith: .failure(deleteError), when: {
            store.completeDeletion(withError: deleteError)
        })
    }
    
    func test_save_failsToInsertNewCacheFeed() {
        let (sut, store) = makeSUT()
        let insertError = anyError()
        
        expect(sut, toCompleteSaveWith: .failure(insertError), when: {
            store.completeDeletionWithSuccess()
            store.completeInsertion(withError: insertError)
        })
    }
    
    func test_save_succeedsToInsertNewCacheFeed() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteSaveWith: .success(()), when: {
            store.completeDeletionWithSuccess()
            store.completeInsertionWithSuccess()
        })
    }
    
    func test_save_doesNotDeliverDeletionErrorAfterSutInstanceIsDeallocated() {
        let timeStamp = Date()
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, timestamp: { timeStamp })
        
        var receivedResult = [LocalFeedLoader.SaveResult]()
        sut?.save([uniqueImage()]) { error in
            receivedResult.append(error)
        }
        
        sut = nil
        store.completeDeletion(withError: anyError())
        
        XCTAssertTrue(receivedResult.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSutInstanceIsDeallocated() {
        let timeStamp = Date()
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, timestamp: { timeStamp })
        
        var receivedResult = [LocalFeedLoader.SaveResult]()
        sut?.save([uniqueImage()]) { error in
            receivedResult.append(error)
        }
        
        store.completeDeletionWithSuccess()
        sut = nil
        store.completeInsertion(withError: anyError())
        
        XCTAssertTrue(receivedResult.isEmpty)
    }
    
    func test_save_doesNotInvokeCompletionOnSuccessfulInsertionAfterSutInstanceIsDeallocated() {
        let timeStamp = Date()
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, timestamp: { timeStamp })
        
        var receivedResult = [LocalFeedLoader.SaveResult]()
        sut?.save([uniqueImage()]) { error in
            receivedResult.append(error)
        }
        
        store.completeDeletionWithSuccess()
        sut = nil
        store.completeInsertionWithSuccess()
        
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

    private func expect(_ sut: LocalFeedLoader, toCompleteSaveWith expectedResult: LocalFeedLoader.SaveResult, when action: @escaping () -> Void) {
        let feeds = [uniqueImage(), uniqueImage()]
        let exp = expectation(description: "Waits for save completion!")
        
        sut.save(feeds) { saveResult in
            
            switch (saveResult, expectedResult) {
                
            case (.success(()), .success(())):
                break
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError)
            default:
                XCTFail("Expected to recived \(expectedResult), found \(saveResult) instead")
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
}
