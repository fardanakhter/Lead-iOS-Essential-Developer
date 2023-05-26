//
//  FeedLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Fardan Akhter on 27/05/2023.
//

import XCTest
import EssentialFeed

class FeedLoaderCacheDecorator: FeedLoader {
    private let decoratee: FeedLoader
    
    init(decoratee: FeedLoader) {
        self.decoratee = decoratee
    }
    
    func load(completion: @escaping (Result<[FeedImage], Error>) -> Void) {
        decoratee.load(completion: completion)
    }
}


class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTestCase {
    
    func test_load_deliversFeedOnSuccess() {
        let feed = uniqueFeed()
        let sut = makeSUT(with: .success(feed))
        
        expect(sut, toCompleteWith: .success(feed))
    }
    
    func test_load_deliversErrorOnFailure() {
        let sut = makeSUT(with: .failure(anyError()))
        
        expect(sut, toCompleteWith: .failure(anyError()))
    }

    // MARK: - Helper
    
    private func makeSUT(with result: FeedLoaderStub.Result) -> FeedLoaderCacheDecorator {
        let loaderStub = FeedLoaderStub(result: result)
        let sut = FeedLoaderCacheDecorator(decoratee: loaderStub)
        trackMemoryLeak(loaderStub)
        trackMemoryLeak(sut)
        return sut
    }
    
}
