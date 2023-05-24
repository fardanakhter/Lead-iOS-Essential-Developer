//
//  FeedLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by Fardan Akhter on 24/05/2023.
//

import XCTest
import EssentialFeed

class FeedLoaderWithFallbackComposite {
    private let primaryLoader: FeedLoader
    private let fallbackLoader: FeedLoader
    
    init(primary: FeedLoader, fallback: FeedLoader) {
        primaryLoader = primary
        fallbackLoader = fallback
    }
    
    func load(completion: @escaping (Result<[FeedImage], Error>) -> Void) {
        primaryLoader.load(completion: completion)
    }
}

class FeedLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let remoteFeed = uniqueFeed()
        let localFeed = uniqueFeed()
        let remoteLoader = LoaderStub(result: .success(remoteFeed))
        let localLoader = LoaderStub(result: .success(localFeed))
        let sut = FeedLoaderWithFallbackComposite(primary: remoteLoader,
                                                  fallback: localLoader)
        
        let exp = expectation(description: "Waiting for load to complete!")
        sut.load { result in
            switch result {
            case let .success(feed):
                XCTAssertEqual(feed, remoteFeed, "Expected received feed to match remote feed")
            default:
                XCTFail("Expected load to complete with success, found \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private class LoaderStub: FeedLoader {
        let result: FeedLoader.Result
        
        init(result: FeedLoader.Result) {
            self.result = result
        }
        
        func load(completion: @escaping (Result<[FeedImage], Error>) -> Void) {
            completion(result)
        }
    }
    
    private func anyURL() -> URL {
        URL(string: "https://any-url.com")!
    }
    
    private func uniqueFeed() -> [FeedImage] {
        [FeedImage(id: UUID(), description: "some-description", location: "some-location", url: anyURL())]
    }
    
}
