//
//  FeedAcceptanceTests.swift
//  EssentialAppTests
//
//  Created by Fardan Akhter on 01/06/2023.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
import EssentialFeedCache
@testable import EssentialApp

final class FeedAcceptanceTests: XCTestCase {
    
    func test_onLaunch_displaysRemoteFeedWhenAppHasConnectivity() {
        let feed = launch(client: .online(response), store: .empty)
        
        XCTAssertEqual(feed.numberOfFeedImageViews, 2)
        XCTAssertNotNil(feed.simulateImageViewVisible(at: 0)?.renderedImage)
        XCTAssertNotNil(feed.simulateImageViewVisible(at: 1)?.renderedImage)
    }
    
    func test_onLaunch_displaysCachedFeedWhenAppHasNoConnectivity() {
        let sharedMemory = InMemoryStoreStub.empty
        let onlineFeed = launch(client: .online(response), store: sharedMemory)
        XCTAssertNotNil(onlineFeed.simulateImageViewVisible(at: 0)?.renderedImage)
        XCTAssertNotNil(onlineFeed.simulateImageViewVisible(at: 1)?.renderedImage)
        
        let offlineFeed = launch(client: .offline, store: sharedMemory)
        
        XCTAssertEqual(offlineFeed.numberOfFeedImageViews, 2)
        XCTAssertNotNil(offlineFeed.simulateImageViewVisible(at: 0)?.renderedImage)
        XCTAssertNotNil(offlineFeed.simulateImageViewVisible(at: 1)?.renderedImage)
    }
    
    func test_onLaunch_displaysEmptyFeedWhenAppHasNoConnectivityAndCacheIsEmpty() {
        let feed = launch(client: .offline, store: .empty)
        
        XCTAssertEqual(feed.numberOfFeedImageViews, 0)
    }
    
    // MARK: - Helpers
    
    private func launch(client: HTTPClientStub, store: InMemoryStoreStub) -> FeedViewController {
        let sut = SceneDelegate(httpClient: client, store: store)
        sut.window = UIWindow()
        sut.configureWindow()
        
        let nav = sut.window?.rootViewController as! UINavigationController
        let feed = nav.topViewController as! FeedViewController
        return feed
    }
    
    private class HTTPClientStub: HTTPClient {
        private struct Task: HTTPClientTask{
            func cancel() {}
        }
        
        private let stub: ((URL) -> HTTPClient.Result)
        
        init(_ stub: (@escaping (URL) -> (HTTPClient.Result))) {
            self.stub = stub
        }
        
        func get(_ url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            completion(stub(url))
            return Task()
        }
        
        static var offline: HTTPClientStub {
            HTTPClientStub { _ in .failure(anyError()) }
        }
        
        static func online(_ stub: @escaping (URL) -> (Data, HTTPURLResponse)) -> HTTPClientStub {
            HTTPClientStub{ url in .success(stub(url)) }
        }
    }
    
    private class InMemoryStoreStub: FeedStore, FeedImageDataStore {
        private(set) var feedCache: CachedFeed?
        private var imageCache: [URL : Data] = [:]
        
        init(feedCache: CachedFeed? = nil) {
            self.feedCache = feedCache
        }
        
        func deleteFeedCache(completion: @escaping FeedStore.DeleteCompletion) {
            feedCache = nil
            completion(.success(()))
        }
        
        func insertFeedCache(with feed: [LocalFeedImage], and timestamp: Date, completion: @escaping FeedStore.InsertCompletion) {
            feedCache = (feed, timestamp)
            completion(.success(()))
        }
        
        func loadFeedCache(completion: @escaping FeedStore.LoadCompletion) {
            completion(.success(feedCache))
        }
        
        func insert(_ cache: Data, with url: URL, completion: @escaping FeedImageDataStore.InsertCompletion) {
            imageCache[url] = cache
            completion(.success(()))
        }
        
        func loadCache(with url: URL, completion: @escaping FeedImageDataStore.LoadCompletion) {
            completion(.success(imageCache[url]))
        }
        
        static var empty: InMemoryStoreStub {
            InMemoryStoreStub()
        }
    }
    
    private func response(for url: URL) -> (Data, HTTPURLResponse) {
        let urlResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: url), urlResponse)
    }
    
    private func makeData(for url: URL) -> Data {
        switch url.absoluteString {
        case "https://image-url.com":
            return makeImageData()
        default:
            return makeFeedData()
        }
    }
    
    private func makeImageData() -> Data {
        return UIImage.make(withColor: .red).pngData()!
    }
    
    private func makeFeedData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": [["id" : UUID().uuidString, "image" : "https://image-url.com"],
                                                                      ["id" : UUID().uuidString, "image" : "https://image-url.com"]]])
    }
    
}
