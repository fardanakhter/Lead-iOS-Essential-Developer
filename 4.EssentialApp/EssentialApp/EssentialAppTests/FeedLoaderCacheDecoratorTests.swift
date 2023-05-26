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
        let loaderStub = FeedLoaderStub(result: .success(feed))
        let sut = FeedLoaderCacheDecorator(decoratee: loaderStub)
        
        expect(sut, toCompleteWith: .success(feed))
    }
    
    func test_load_deliversErrorOnFailure() {
        let loaderStub = FeedLoaderStub(result: .failure(anyError()))
        let sut = FeedLoaderCacheDecorator(decoratee: loaderStub)
        
        expect(sut, toCompleteWith: .failure(anyError()))
    }

}
