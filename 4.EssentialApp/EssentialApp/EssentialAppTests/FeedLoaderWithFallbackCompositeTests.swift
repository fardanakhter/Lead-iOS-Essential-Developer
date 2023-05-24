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
        primaryLoader.load {[weak self] primaryResult in
            switch primaryResult {
            case let .success(primaryFeed):
                completion(.success(primaryFeed))
            case .failure:
                self?.fallbackLoader.load(completion: completion)
            }
        }
    }
}

class FeedLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let remoteFeed = uniqueFeed()
        let sut = makeSUT(primaryResult: .success(remoteFeed), fallbackResult: .success(uniqueFeed()))
        
        expect(sut, toLoadSuccessfullyWith: remoteFeed)
    }
    
    func test_load_deliversFallbackFeedOnPrimaryLoaderFailureAndFallbackSuccess() {
        let localFeed = uniqueFeed()
        let sut = makeSUT(primaryResult: .failure(anyError()), fallbackResult: .success(localFeed))
        
        expect(sut, toLoadSuccessfullyWith: localFeed)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(primaryResult: FeedLoader.Result, fallbackResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) -> FeedLoaderWithFallbackComposite {
        let remoteLoader = LoaderStub(result: primaryResult)
        let localLoader = LoaderStub(result: fallbackResult)
        let sut = FeedLoaderWithFallbackComposite(primary: remoteLoader,
                                                  fallback: localLoader)
        trackMemoryLeak(remoteLoader, file: file, line: line)
        trackMemoryLeak(localLoader, file: file, line: line)
        trackMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: FeedLoaderWithFallbackComposite, toLoadSuccessfullyWith expectedFeed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Waiting for load to complete!")
        sut.load { result in
            switch result {
            case let .success(feed):
                XCTAssertEqual(feed, expectedFeed, "Expected received feed to match remote feed", file: file, line: line)
            default:
                XCTFail("Expected load to complete with success, found \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
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
    
    private func anyError() -> NSError {
        NSError(domain: "any-error", code: 0)
    }
    
    private func uniqueFeed() -> [FeedImage] {
        [FeedImage(id: UUID(), description: "some-description", location: "some-location", url: anyURL())]
    }
    
}
