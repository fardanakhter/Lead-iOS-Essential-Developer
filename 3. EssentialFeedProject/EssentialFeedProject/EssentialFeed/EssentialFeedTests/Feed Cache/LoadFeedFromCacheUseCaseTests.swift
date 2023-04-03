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
    
    func test_load_deliversFeedImagesWhenTimestampIsLessThanSevenDaysOld() {
        let currentDate = Date()
        let (sut, store) = makeSUT({ currentDate })
        let imageFeeds = uniqueImageFeeds()
        
        expect(sut, toCompleteWith: .success(imageFeeds.models), when: {
            let lessThanSevenDaysOld = Date().addingDay(-7).addingSeconds(1)
            store.completeLoad(with: imageFeeds.local, timestamp: lessThanSevenDaysOld)
        })
    }
    
    func test_load_deliversNoFeedImageWhenTimestampIsMoreThanSevenDaysOld() {
        let currentDate = Date()
        let (sut, store) = makeSUT({ currentDate })
        let imageFeeds = uniqueImageFeeds()
        
        expect(sut, toCompleteWith: .success([]), when: {
            let lessThanSevenDaysOld = Date().addingDay(-7).addingSeconds(-1)
            store.completeLoad(with: imageFeeds.local, timestamp: lessThanSevenDaysOld)
        })
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
    
    private func uniqueImage() -> FeedImage {
        return FeedImage(id: UUID(), description: nil, location: nil, url: anyURL())
    }
    
    private func uniqueImageFeeds() -> (models: [FeedImage], local: [LocalFeedImage]) {
        let feeds = [uniqueImage(), uniqueImage()]
        let localFeeds = feeds.map {
            LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
        }
        return (feeds, localFeeds)
    }
    
    private func anyError() -> NSError {
        NSError(domain: "Test", code: 0)
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
    
}

private extension Date {
    func addingDay(_ day: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: day, to: self)!
    }
    
    func addingSeconds(_ timeInterval: TimeInterval) -> Date {
        return self + timeInterval
    }
}

