//
//  FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 11/04/2023.
//

import Foundation

protocol FeedStoreSpecs {
     func test_loadFeedCache_returnsEmptyResultOnRetrievingEmptyCache()
     func test_loadFeedCache_hasNoSideEffectWhenRetrivingEmptyCacheTwice()
     func test_loadFeedCache_deliversLastInsertedCache()
     func test_loadFeedCache_hasNoSideEffectWhenRetrievingNonEmptyCacheTwice()
    
     func test_insertFeedCache_doesNotDeliverErrorOnEmptyCache()
     func test_insertFeedCache_overridesLastCacheWithLatestCache()

     func test_deleteFeedCache_doesNotDeliverErrorWhenCacheIsEmpty()
     func test_deleteFeedCache_hasNoSideEffectWhenCacheIsEmpty()
     func test_deleteFeedCache_doesNotDeliverErrorWhenCacheIsNonEmpty()
     func test_deleteFeedCache_emptiesPreviouslyInsertedCache()

     func test_storeSideEffects_runSerially()
}

protocol FailableLoadFeedStoreSpecs: FeedStoreSpecs {
    func test_loadFeedCache_deliversErrorWhenRetrievingCacheFails()
    func test_loadFeedCache_hasNoSideEffectWhenRetrievingCacheFailsTwice()
}

protocol FailableInsertFeedStoreSpecs: FeedStoreSpecs {
    func test_insertFeedCache_deliversErrorWhenCacheInsertionFails()
    func test_insertFeedCache_hasNoSideEffectWhenCacheInsertionFails()
}

protocol FailableDeleteFeedStoreSpecs: FeedStoreSpecs {
    func test_deleteFeedCache_deliversErrorWhenCacheDeletionFails()
    func test_deleteFeedCache_hasNoSideEffectWhenCacheDeletionFails()
}

typealias FailableFeedStoreSpecs = FailableLoadFeedStoreSpecs & FailableInsertFeedStoreSpecs & FailableDeleteFeedStoreSpecs
