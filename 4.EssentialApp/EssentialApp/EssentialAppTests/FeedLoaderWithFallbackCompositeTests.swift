//
//  FeedLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by Fardan Akhter on 24/05/2023.
//

import XCTest
import EssentialFeed
import EssentialApp

class FeedLoaderWithFallbackCompositeTests: XCTestCase, FeedLoaderTestCase {
    
    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryFeed = uniqueFeed()
        let sut = makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(uniqueFeed()))
        
        expect(sut, toCompleteWith: .success(primaryFeed))
    }
    
    func test_load_deliversFallbackFeedOnPrimaryLoaderFailureAndFallbackSuccess() {
        let fallbackFeed = uniqueFeed()
        let sut = makeSUT(primaryResult: .failure(anyError()), fallbackResult: .success(fallbackFeed))
        
        expect(sut, toCompleteWith: .success(fallbackFeed))
    }
    
    func test_load_deliversErorrOnBothPrimaryAndFallbackLoaderFailure() {
        let sut = makeSUT(primaryResult: .failure(anyError()), fallbackResult: .failure(anyError()))
        
        expect(sut, toCompleteWith: .failure(anyError()))
    }
    
    // MARK: - Helpers
    
    private func makeSUT(primaryResult: FeedLoader.Result, fallbackResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) -> FeedLoaderWithFallbackComposite {
        let remoteLoader = FeedLoaderStub(result: primaryResult)
        let localLoader = FeedLoaderStub(result: fallbackResult)
        let sut = FeedLoaderWithFallbackComposite(primary: remoteLoader,
                                                  fallback: localLoader)
        trackMemoryLeak(remoteLoader, file: file, line: line)
        trackMemoryLeak(localLoader, file: file, line: line)
        trackMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
}
