//
//  FeedLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Fardan Akhter on 27/05/2023.
//

import XCTest
import EssentialFeed
import EssentialApp

class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTestCase {
    
    func test_load_deliversFeedOnSuccess() {
        let feed = uniqueFeed()
        let (sut, _) = makeSUT(with: .success(feed))
        
        expect(sut, toCompleteWith: .success(feed))
    }
    
    func test_load_deliversErrorOnFailure() {
        let (sut, _) = makeSUT(with: .failure(anyError()))
        
        expect(sut, toCompleteWith: .failure(anyError()))
    }
    
    func test_load_cachesFeedOnSuccess() {
        let feed = uniqueFeed()
        let (sut, cache) = makeSUT(with: .success(feed))
        
        sut.load { _ in }
        
        XCTAssertEqual(cache.messages, [.save(feed)])
    }
    
    func test_load_doesNotCachesFeedOnFailure() {
        let (sut, cache) = makeSUT(with: .failure(anyError()))
        
        sut.load { _ in }
        
        XCTAssertEqual(cache.messages, [])
    }

    // MARK: - Helper
    
    private func makeSUT(with result: FeedLoaderStub.Result, file: StaticString = #file, line: UInt = #line) -> (sut: FeedLoaderCacheDecorator, cache: CacheSpy) {
        let loaderStub = FeedLoaderStub(result: result)
        let cache = CacheSpy()
        let sut = FeedLoaderCacheDecorator(decoratee: loaderStub, cache: cache)
        trackMemoryLeak(loaderStub, file: file, line: line)
        trackMemoryLeak(cache, file: file, line: line)
        trackMemoryLeak(sut, file: file, line: line)
        return (sut, cache)
    }
    
    private class CacheSpy: FeedCache {
        private(set) var messages = [Message]()
        
        enum Message: Equatable {
            case save([FeedImage])
        }
        
        func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
            messages.append(.save(feed))
        }
    }
    
}
