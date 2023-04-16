//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 08/04/2023.
//

import XCTest
import EssentialFeed

final class CodableFeedStoreTests: XCTestCase, FailableFeedStoreSpecs {

    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }
    
    func test_loadFeedCache_deliversEmptyOnRetrievingEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    func test_loadFeedCache_hasNoSideEffectWhenRetrivingEmptyCacheTwice() {
        let sut = makeSUT()

        assertThatRetrieveHasNoSideEffectOnEmptyCache(on: sut)
    }
    
    func test_loadFeedCache_deliversLastInsertedNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveDeliversLastInsertedNonEmptyCache(on: sut)
    }
    
    func test_loadFeedCache_hasNoSideEffectWhenRetrievingNonEmptyCacheTwice() {
        let sut = makeSUT()
        
        assertThatRetrieveHasNoSideEffectOnNonEmptyCache(on: sut)
    }
    
    func test_loadFeedCache_deliversErrorWhenRetrievingCacheFails() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        assertThatRetrieveDeliversErrorOnFailure(on: sut)
    }
    
    func test_loadFeedCache_hasNoSideEffectWhenRetrievingCacheFailsTwice() {
        let sut = makeSUT()
        
        try! "invalid data".write(to: testSpecificStoreURL(), atomically: false, encoding: .utf8)
        
        assertThatRetrieveHasNoSideEffectOnFailure(on: sut)
    }
    
    func test_insertFeedCache_doesNotDeliverErrorOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatInsertDoesNotDeliverErrorOnEmptyCache(on: sut)
    }
    
    func test_insertFeedCache_deliversErrorWhenCacheInsertionFails() {
        let invalidStoreURL = anyInvalidURL()
        let sut = makeSUT(invalidStoreURL)
        
        assertThatInsertionDeliversErrorOnFailure(on: sut)
    }
    
    func test_insertFeedCache_hasNoSideEffectWhenCacheInsertionFails() {
        let invalidStoreURL = anyInvalidURL()
        let sut = makeSUT(invalidStoreURL)

        assertThatInsertionHasNoSideEffectOnFailure(on: sut)
    }
    
    func test_insertFeedCache_overridesLastCacheWithLatestCache() {
        let sut = makeSUT()
        
        assertThatInsertionOverridesPreviouslyInsertedCache(on: sut)
    }
    
    func test_deleteFeedCache_doesNotDeliverErrorWhenCacheIsEmpty() {
        let sut = makeSUT()

        assertThatDeletionDoesNotDeliverErrorOnEmptyCache(on: sut)
    }
    
    func test_deleteFeedCache_hasNoSideEffectWhenCacheIsEmpty() {
        let sut = makeSUT()

        assertThatDeletionHasNoSideEffectWhenCacheIsEmpty(on: sut)
    }
    
    func test_deleteFeedCache_doesNotDeliverErrorWhenCacheIsNonEmpty() {
        let sut = makeSUT()
        
        assertThatDeletionDoesNotDeliverErrorWhenCacheIsNonEmpty(on: sut)
    }
    
    func test_deleteFeedCache_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        
        assertThatDeletionEmptiesPreviouslyInsertedCache(on: sut)
    }
    
    func test_deleteFeedCache_deliversErrorWhenCacheDeletionFails() {
        let nonPermissableDirectory = noDeleteAccessDirectory()
        let sut = makeSUT(nonPermissableDirectory)

        assertThatDeletionDeliversErrorOnFailure(on: sut)
    }
    
    func test_deleteFeedCache_hasNoSideEffectWhenCacheDeletionFails() {
        let nonPermissableDirectory = noDeleteAccessDirectory()
        let sut = makeSUT(nonPermissableDirectory)

        assertThatDeletionHasNoSideEffectOnFailure(on: sut)
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        
        assertThatSideEffectsRunsSerially(on: sut)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(_ storeURL: URL? = nil) -> FeedStore {
        let sut = CodableFeedStore(storeURL ?? testSpecificStoreURL())
        trackMemoryLeak(sut)
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathExtension("\(type(of: self)).store")
    }
    
    private func noDeleteAccessDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func anyInvalidURL() -> URL {
        URL(string: "invalid://store-url")!
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
