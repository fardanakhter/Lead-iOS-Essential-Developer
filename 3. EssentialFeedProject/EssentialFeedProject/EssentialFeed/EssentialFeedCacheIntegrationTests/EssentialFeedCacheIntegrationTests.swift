//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by Fardan Akhter on 13/04/2023.
//

import XCTest
import EssentialFeed

final class EssentialFeedCacheIntegrationTests: XCTestCase {

    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }
    
    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT().loader
        
        let exp = expectation(description: "Waits for load to complete")
        sut.load { result in
            switch result {
            case let .success(images):
                XCTAssertEqual(images, [])
            default:
                XCTFail("Expected success with empty images, found \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_deliversItemsWhenSavedOnAnotherInstance() {
        let sutToPerformSave = makeSUT().loader
        let sutToPerformLoad = makeSUT().loader
        let feed = uniqueImageFeeds().models
        
        let saveExp = expectation(description: "Waits for save to complete")
        sutToPerformSave.save(feed) { error in
            XCTAssertNil(error, "Expected to save items successfully")
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
        
        let loadExp = expectation(description: "Waits for load to complete")
        var recievedCache = [FeedImage]()
        sutToPerformLoad.load { result in
            switch result {
            case let .success(cachedFeed):
                recievedCache = cachedFeed
            default:
                XCTFail("Expected to load with items, found \(result) instead")
            }
            loadExp.fulfill()
        }
        
        wait(for: [loadExp], timeout: 1.0)
        
        XCTAssertEqual(recievedCache, feed)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(_ timeStamp: () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (loader: LocalFeedLoader, store: FeedStore) {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        let sut = LocalFeedLoader(store: store, timestamp: timeStamp)
        trackMemoryLeak(store, file: file, line: line)
        trackMemoryLeak(sut, file: file, line: line)
        return (sut, store)
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
    
    private func testSpecificStoreURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathExtension("\(type(of:self)).store")
    }

}
