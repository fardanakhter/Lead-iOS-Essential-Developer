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
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            feed.map { $0.local }
        }
    }
    
    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        init(from model: LocalFeedImage) {
            self.id = model.id
            self.description = model.description
            self.location = model.location
            self.url = model.url
        }
        
        var local: LocalFeedImage {
            LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    let storeURL: URL
    
    init(_ storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func insertFeedCache(with feed: [LocalFeedImage], and timestamp: Date, completion: @escaping FeedStore.InsertCompletion) {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp))
        
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
        completion(.found(feed: cahedFeed.localFeed, timestamp: cahedFeed.timestamp))
    }
}

final class CodableFeedStoreTests: XCTestCase {

    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }
    
    func test_loadFeedCache_returnsEmptyResultOnEmptyCache() {
        let sut = makeSUT()
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
        let sut = makeSUT()
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
        let sut = makeSUT()
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
    
    // MARK: - Helpers
    
    private func makeSUT() -> CodableFeedStore {
        let storeURL = testSpecificStoreURL()
        let sut = CodableFeedStore(storeURL)
        trackMemoryLeak(sut)
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathExtension("\(type(of: self)).store")
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
