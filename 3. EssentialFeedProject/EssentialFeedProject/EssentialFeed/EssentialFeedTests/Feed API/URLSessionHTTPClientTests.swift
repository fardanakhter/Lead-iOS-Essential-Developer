//
//  HTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 26/03/2023.
//

import XCTest
import EssentialFeed

// Production Code
class URLSessionHTTPClient: HTTPClient {
    
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(_ url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        let dataTask = session.dataTask(with: url) { _, _, _ in }
        dataTask.resume()
    }
}

// Test Code
final class URLSessionHTTPClientTests: XCTestCase {

    func test_get_createsDataTaskWithURL() {
        let url = URL(string: "https://a-url.com")!
        let session = URLSessionSpy()
        
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(url) { _ in }
        
        XCTAssertEqual(session.requestedURLs, [url])
    }
    
    func test_get_resumesDataTaskWithURL() {
        let url = URL(string: "https://a-url.com")!
        let sessionSpy = URLSessionSpy()
        let dataTaskSpy = URLSesssionDataTaskSpy()
        sessionSpy.stubs[url] = dataTaskSpy
        
        let sut = URLSessionHTTPClient(session: sessionSpy)
        
        sut.get(url) { _ in }
        
        XCTAssertEqual(dataTaskSpy.resumeCount, 1)
    }
    
    // Helpers
    
    class URLSessionSpy: URLSession {
        var requestedURLs = [URL]()
        var stubs = [URL : URLSesssionDataTaskSpy]()
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            requestedURLs.append(url)
            return stubs[url] ?? FakeURLSessionDataTask()
        }
    }
    
    class FakeURLSessionDataTask: URLSessionDataTask {
        override func resume() {}
    }
    
    class URLSesssionDataTaskSpy: URLSessionDataTask {
        var resumeCount: Int = 0
        
        override func resume() {
            resumeCount += 1
        }
    }
    
}
