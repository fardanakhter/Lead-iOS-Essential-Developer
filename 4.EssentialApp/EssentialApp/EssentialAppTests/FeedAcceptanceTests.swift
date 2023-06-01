//
//  FeedAcceptanceTests.swift
//  EssentialAppTests
//
//  Created by Fardan Akhter on 01/06/2023.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
@testable import EssentialApp

final class FeedAcceptanceTests: XCTestCase {
    
    func test_onLaunch_displaysRemoteFeedWhenAppHasConnectivity() {
        let clientStub = HTTPClientStub.online()
        let storeStub = InMemoryStoreStub()
        let sut = SceneDelegate(httpClient: clientStub, store: storeStub)
        sut.window = UIWindow()
        sut.configureWindow()
        
        let nav = sut.window?.rootViewController as! UINavigationController
        let feed = nav.topViewController as! FeedViewController
        
        XCTAssertEqual(feed.numberOfFeedImageViews, 2)
        XCTAssertNotNil(feed.simulateImageViewVisible(at: 0)?.renderedImage)
        XCTAssertNotNil(feed.simulateImageViewVisible(at: 1)?.renderedImage)
    }
    
    func test_onLaunch_displaysCachedFeedWhenAppHasNoConnectivity() {
        
    }
    
    func test_onLaunch_displaysEmptyFeedWhenAppHasNoConnectivityAndCacheIsEmpty() {
        
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
        
        static func online() -> HTTPClientStub {
            HTTPClientStub{ url in .success(makeSuccessfulResponse(for: url)) }
        }
    }
    
    private class InMemoryStoreStub: FeedStore, FeedImageDataStore {
        private var feedCache: CachedFeed?
        private var imageCache = [URL : Data]()
        
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
    }
    
    private static func makeSuccessfulResponse(for url: URL) -> (Data, HTTPURLResponse) {
        let urlResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: url), urlResponse)
    }
    
    private static func makeData(for url: URL) -> Data {
        switch url.absoluteString {
        case "https://any-url.com":
            return makeImageData()
        default:
            return makeFeedData()
        }
    }
    
    private static func makeImageData() -> Data {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.red.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!.pngData()!
    }
    
    private static func makeFeedData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": [["id" : UUID().uuidString, "image" : "https://any-url.com"],
                                                                      ["id" : UUID().uuidString, "image" : "https://any-url.com"]]])
    }
    
}
