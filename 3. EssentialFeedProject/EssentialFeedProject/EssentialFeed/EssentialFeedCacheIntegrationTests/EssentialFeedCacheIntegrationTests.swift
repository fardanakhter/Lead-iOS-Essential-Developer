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
        let sut = makeSUT()
        
        expect(sut, toLoad: .success([]))
    }
    
    func test_load_deliversItemsWhenSavedOnAnotherInstance() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let feed = uniqueImageFeeds().models
        
        let saveExp = expectation(description: "Waits for save to complete")
        sutToPerformSave.save(feed) { error in
            XCTAssertNil(error, "Expected to save items successfully")
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
        
        expect(sutToPerformLoad, toLoad: .success(feed))
    }
    
    func test_save_overidesItemsSavedByAnotherInstance() {
        let sutToPerformFirstSave = makeSUT()
        let sutToPerformSecondSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let firstFeed = uniqueImageFeeds().models
        let latestFeed = uniqueImageFeeds().models

        let firstSaveOperation = expectation(description: "Waits for first save completion")
        sutToPerformFirstSave.save(firstFeed) { error in
            XCTAssertNil(error, "Expected to save successfully")
            firstSaveOperation.fulfill()
        }
        wait(for: [firstSaveOperation], timeout: 1.0)
        
        let secondSaveOperation = expectation(description: "Waits for second save completion")
        sutToPerformSecondSave.save(latestFeed) { error in
            XCTAssertNil(error, "Expected to save successfully")
            secondSaveOperation.fulfill()
        }
        wait(for: [secondSaveOperation], timeout: 1.0)
        
        expect(sutToPerformLoad, toLoad: .success(latestFeed))
    }
    
    //MARK: - Helpers
    
    private func makeSUT(_ timeStamp: () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        let sut = LocalFeedLoader(store: store, timestamp: timeStamp)
        trackMemoryLeak(store, file: file, line: line)
        trackMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: LocalFeedLoader, toLoad expectedResult: LocalFeedLoader.LoadResult, file: StaticString = #file, line: UInt = #line) {
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
        
        wait(for: [exp], timeout: 1.0)
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
