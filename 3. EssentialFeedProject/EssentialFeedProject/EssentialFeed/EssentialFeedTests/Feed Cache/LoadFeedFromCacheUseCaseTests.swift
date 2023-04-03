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
    
    //MARK: - Helpers
    
    private func makeSUT(_ timeStamp: () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (loader: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let loader = LocalFeedLoader(store: store, timestamp: timeStamp)
        trackMemoryLeak(store, file: file, line: line)
        trackMemoryLeak(loader, file: file, line: line)
        return (loader, store)
    }
    
    class FeedStoreSpy: FeedStore {
        
        enum ReceivedMessages: Equatable {
            case deleteCacheFeed
            case insertCacheFeed([LocalFeedImage], Date)
            case loadImageFeed
        }
        
        private var completionsForDeletion = [DeleteCompletion]()
        private var completionsForInsertion = [InsertCompletion]()
        
        private(set) var receivedMessages = [ReceivedMessages]()
        
        func deleteFeedCache(completion: @escaping DeleteCompletion) {
            completionsForDeletion.append(completion)
            receivedMessages.append(.deleteCacheFeed)
        }
        
        func completeDeletion(withError error: NSError, at index: Int = 0) {
            completionsForDeletion[index](error)
        }
        
        func completeDeletionWithSuccess(at index: Int = 0) {
            completionsForDeletion[index](nil)
        }
        
        func insertFeedCache(with feed: [LocalFeedImage], and timestamp: Date, completion: @escaping InsertCompletion) {
            completionsForInsertion.append(completion)
            receivedMessages.append(.insertCacheFeed(feed, timestamp))
        }
        
        func completeInsertion(withError error: NSError, at index: Int = 0) {
            completionsForInsertion[index](error)
        }
        
        func completeInsertionWithSuccess(at index: Int = 0) {
            completionsForInsertion[index](nil)
        }
        
    }
}
