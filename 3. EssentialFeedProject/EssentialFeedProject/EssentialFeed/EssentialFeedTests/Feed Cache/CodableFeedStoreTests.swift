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
    
    func deleteFeedCache(completion: @escaping FeedStore.DeleteCompletion) {
        guard FileManager.default.fileExists(atPath: storeURL.path) else {
            return completion(nil)
        }
        
        do {
            try FileManager.default.removeItem(at: storeURL)
            completion(nil)
        }
        catch(let error) {
            completion(error)
        }
    }
    
    func insertFeedCache(with feed: [LocalFeedImage], and timestamp: Date, completion: @escaping FeedStore.InsertCompletion) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp))
            try data.write(to: storeURL)
            completion(nil)
        }
        catch(let error) {
            completion(error)
        }
    }
    
    func loadFeedCache(completion: @escaping FeedStore.LoadCompletion) {
        guard let cachedData = try? Data(contentsOf: storeURL) else {
            completion(.empty)
            return
        }

        do {
            let decoder = JSONDecoder()
            let cahedFeed = try decoder.decode(Cache.self, from: cachedData)
            completion(.found(feed: cahedFeed.localFeed, timestamp: cahedFeed.timestamp))
        }
        catch(let error) {
            completion(.failure(error))
        }
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
    
    func test_loadFeedCache_returnsEmptyResultOnRetrievingEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toCompleteRetrievalWith: .empty)
    }
    
    func test_loadFeedCache_hasNoSideEffectWhenRetrivingEmptyCacheTwice() {
        let sut = makeSUT()
        
        expect(sut, toCompleteRetrievalWith: .empty)
        expect(sut, toCompleteRetrievalWith: .empty)
    }
    
    func test_loadFeedCache_deliversLastInsertedCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeeds().local
        let timestamp = Date.init()
        
        let insertionError = expect(sut, toInsert: (feed, timestamp))
        XCTAssertNil(insertionError, "Expected to insert cache successfully")
        expect(sut, toCompleteRetrievalWith: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_loadFeedCache_hasNoSideEffectWhenRetrievingNonEmptyCacheTwice() {
        let sut = makeSUT()
        let feed = uniqueImageFeeds().local
        let timestamp = Date.init()
        
        let insertionError = expect(sut, toInsert: (feed, timestamp))
        XCTAssertNil(insertionError, "Expected to insert cache successfully")
        expect(sut, toCompleteRetrievalWith: .found(feed: feed, timestamp: timestamp))
        expect(sut, toCompleteRetrievalWith: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_loadFeedCache_deliversErrorWhenRetrievingCacheFails() {
        let sut = makeSUT()
        
        try! "invalid data".write(to: testSpecificStoreURL(), atomically: false, encoding: .utf8)
        
        expect(sut, toCompleteRetrievalWith: .failure(anyError()))
    }
    
    func test_loadFeedCache_hasNoSideEffectWhenRetrievingCacheFailsTwice() {
        let sut = makeSUT()
        
        try! "invalid data".write(to: testSpecificStoreURL(), atomically: false, encoding: .utf8)
        
        expect(sut, toCompleteRetrievalWith: .failure(anyError()))
        expect(sut, toCompleteRetrievalWith: .failure(anyError()))
    }
    
    func test_insertFeedCache_overridesLastCacheWithLatestCache() {
        let sut = makeSUT()
        
        let firstCache = (feed: uniqueImageFeeds().local, timestamp: Date())
        let firstInsertionError = expect(sut, toInsert: firstCache)
        XCTAssertNil(firstInsertionError, "Expected to insert cache successfully")
        
        let secondCache = (feed: uniqueImageFeeds().local, timestamp: Date())
        let secondInsertionError = expect(sut, toInsert: secondCache)
        XCTAssertNil(secondInsertionError, "Expected to override cache successfully")
        
        expect(sut, toCompleteRetrievalWith: .found(feed: secondCache.feed, timestamp: secondCache.timestamp))
    }
    
    func test_insertFeedCache_deliversErrorWhenCacheInsertionFails() {
        let invalidStoreURL = URL(string: "//:invlaid-directory.store")!
        let sut = makeSUT(invalidStoreURL)
        
        let insertionError: Error?
        insertionError = expect(sut, toInsert: (uniqueImageFeeds().local, Date()))
        XCTAssertNotNil(insertionError, "Expected error in inserting cache")
    }
    
    func test_deleteFeedCache_doesNotDeleteEmptyCacheAndResultsInNoError() {
        let sut = makeSUT()
        
        expect(sut, toCompleteRetrievalWith: .empty)
        let exp = expectation(description: "Waits for delete completion")
        sut.deleteFeedCache { error in
            XCTAssertNil(error, "Expected to delete with no error")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        expect(sut, toCompleteRetrievalWith: .empty)
    }
    
    func test_deleteFeedCache_deletesNonEmptyCacheAndLeavesCacheEmpty() {
        let sut = makeSUT()
        
        expect(sut, toInsert: (uniqueImageFeeds().local, Date()))
        
        let exp = expectation(description: "Waits for delete completion")
        sut.deleteFeedCache { error in
            XCTAssertNil(error, "Expected to delete with no error")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        expect(sut, toCompleteRetrievalWith: .empty)
    }
    
    func test_deleteFeedCache_deliversErrorWhenCacheDeletionFails() {
        let nonPermissableDirectory = noDeleteAccessDirectory()
        let sut = makeSUT(nonPermissableDirectory)
        
        let exp = expectation(description: "Waits for delete completion")
        var deletionError: Error?
        sut.deleteFeedCache { error in
            deletionError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)

        XCTAssertNotNil(deletionError, "Expected to delete with error")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(_ storeURL: URL? = nil) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL ?? testSpecificStoreURL())
        trackMemoryLeak(sut)
        return sut
    }
    
    private func expect(_ sut: CodableFeedStore, toCompleteRetrievalWith expectedResult: LoadFeedCacheResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Waits for loadFeedCache completion")

        sut.loadFeedCache { result in
            switch (result, expectedResult) {
            case (.empty, .empty), (.failure, .failure):
                break
                
            case let (.found(feed, timestamp), .found(expectedFeed, expectedTimestamp)):
                XCTAssertEqual(feed, expectedFeed)
                XCTAssertEqual(timestamp, expectedTimestamp)
                
            default:
                XCTFail("Expected \(expectedResult), got \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    @discardableResult
    private func expect(_ sut: CodableFeedStore, toInsert cache: (feed: [LocalFeedImage], timestamp: Date), file: StaticString = #file, line: UInt = #line) -> Error? {
        let exp = expectation(description: "Waits for loadFeedCache completion")
        
        var receivedError: Error?
        sut.insertFeedCache(with: cache.feed, and: cache.timestamp) { error in
            receivedError = error
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedError
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
    
    private func noDeleteAccessDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
