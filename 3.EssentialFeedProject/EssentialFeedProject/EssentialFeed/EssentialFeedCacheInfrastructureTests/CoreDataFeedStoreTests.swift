//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 12/04/2023.
//

import XCTest
import EssentialFeedCache
import EssentialFeedCacheInfrastructure

final class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
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
    
    func test_insertFeedCache_doesNotDeliverErrorOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatInsertDoesNotDeliverErrorOnEmptyCache(on: sut)
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
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        
        assertThatSideEffectsRunsSerially(on: sut)
    }
    
    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        trackMemoryLeak(sut)
        return sut
    }
}
