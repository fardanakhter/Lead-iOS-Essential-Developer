//
//  FeedImageDataLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Fardan Akhter on 27/05/2023.
//

import XCTest
import EssentialFeed
import EssentialApp

class FeedImageDataLoaderCacheDecoratorTests: XCTestCase, FeedImageDataLoaderTestCase {
    
    func test_load_deliversFeedOnSuccess() {
        let imageData = anyData()
        let loader = FeedImageDataLoaderSpy()
        let (sut, _) = makeSUT(with: loader)
        
        expect(sut, toCompleteWith: .success(imageData), when: {
            loader.complete(with: imageData)
        })
    }
    
    func test_load_deliversErrorOnFailure() {
        let loader = FeedImageDataLoaderSpy()
        let (sut, _) = makeSUT(with: loader)
        
        expect(sut, toCompleteWith: .failure(anyError()), when: {
            loader.complete(with: anyError())
        })
    }
    
    func test_cancelTask_cancelsLoad() {
        let url = anyURL()
        let loader = FeedImageDataLoaderSpy()
        let (sut, _) = makeSUT(with: loader)

        let task = sut.load(url) { _ in }
        task.cancel()
        
        XCTAssertEqual(loader.cancelledURLs, [url], "Expected to cancel URL loading from primary loader")
    }

    func test_load_cachesFeedOnSuccess() {
        let imageUrl = anyURL()
        let imageData = anyData()
        let loader = FeedImageDataLoaderSpy()
        let (sut, cache) = makeSUT(with: loader)
        
        let _ = sut.load(imageUrl) { _ in }
        loader.complete(with: imageData)
        
        XCTAssertEqual(cache.messages, [.save(with: imageUrl, cache: imageData)])
    }
    
    func test_load_doesNotCachesFeedOnFailure() {
        let loader = FeedImageDataLoaderSpy()
        let (sut, cache) = makeSUT(with: loader)
        
        let _ = sut.load(anyURL()) { _ in }
        loader.complete(with: anyError())
        
        XCTAssertEqual(cache.messages, [])
    }

    // MARK: - Helper
    
    private func makeSUT(with loaderSpy: FeedImageDataLoaderSpy, file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoaderCacheDecorator, cache: CacheSpy) {
        let cache = CacheSpy()
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: loaderSpy, cache: cache)
        trackMemoryLeak(loaderSpy, file: file, line: line)
        trackMemoryLeak(cache, file: file, line: line)
        trackMemoryLeak(sut, file: file, line: line)
        return (sut, cache)
    }
    
    private class CacheSpy: FeedImageDataCache {
        private(set) var messages = [Message]()
        
        enum Message: Equatable {
            case save(with: URL,cache: Data)
        }
        
        func save(_ cache: Data, with url: URL, completion: @escaping (SaveResult) -> Void) {
            messages.append(.save(with: url, cache: cache))
        }
    }
    
}


