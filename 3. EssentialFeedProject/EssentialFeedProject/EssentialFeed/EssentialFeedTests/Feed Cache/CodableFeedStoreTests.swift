//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 08/04/2023.
//

import XCTest
import EssentialFeed

final class CodableFeedStore {
    func loadFeedCache(completion: @escaping FeedStore.LoadCompletion) {
        completion(.empty)
    }
}

final class CodableFeedStoreTests: XCTestCase {

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
    
}
