//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 08/04/2023.
//

import XCTest
import EssentialFeed

private final class CodableFeedStore {
    
    private struct Cache: Codable {
        let feed: [LocalFeedImage]
        let timestamp: Date
    }
    
    let storeURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathExtension("image-feed-cache.store")
    
    func insertFeedCache(with feed: [LocalFeedImage], and timestamp: Date, completion: @escaping FeedStore.InsertCompletion) {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(Cache(feed: feed, timestamp: timestamp))
        
        try! data.write(to: storeURL)
        completion(nil)
    }
    
    func loadFeedCache(completion: @escaping FeedStore.LoadCompletion) {
        guard let cachedData = try? Data(contentsOf: storeURL) else {
            completion(.empty)
            return
        }

        let decoder = JSONDecoder()
        let cahedFeed = try! decoder.decode(Cache.self, from: cachedData)
        completion(.found(feed: cahedFeed.feed, timestamp: cahedFeed.timestamp))
    }
}

final class CodableFeedStoreTests: XCTestCase {

    override func setUp() {
        super.setUp()
        let storeURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathExtension("image-feed-cache.store")
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    override class func tearDown() {
        super.tearDown()
        let storeURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathExtension("image-feed-cache.store")
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    func test_loadFeedCache_returnsEmptyResultOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "Waits for loadFeedCache completion")
        
        sut.loadFeedCache { result in
            switch result {
            case .empty:
                break
                
            default:
                XCTFail("Expected result with empty cache, got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadFeedCache_returnsEmptyResultsOnRetrivingEmptyCacheTwice() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "Waits for loadFeedCache completion")
        
        sut.loadFeedCache { firstResult in
            sut.loadFeedCache { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                    
                default:
                    XCTFail("Expected results with empty cache, got \(firstResult) and \(secondResult) instead")
                }
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieveAfterInserting_deliversInsertedCache() {
        let sut = CodableFeedStore()
        let localFeedImages = uniqueImageFeeds().local
        let timestamp = Date.init()
        let exp = expectation(description: "Waits for loadFeedCache completion")
        
        sut.insertFeedCache(with: localFeedImages, and: timestamp) { error in
            XCTAssertNil(error, "Failed to insert feed cache")
            sut.loadFeedCache { result in
                switch result {
                case let .found(feed: cachedFeed, timestamp: cachedTimestamp):
                    XCTAssertEqual(cachedFeed, localFeedImages)
                    XCTAssertEqual(cachedTimestamp, timestamp)
                
                default:
                    XCTFail("Expected result with non-empty cache, got \(result) instead")
                }
                
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
