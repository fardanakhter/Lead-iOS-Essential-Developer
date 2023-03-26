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
        let dataTask = session.dataTask(with: url) { _, _, error in
            if let error {
                completion(.failure(error))
            }
        }
        dataTask.resume()
    }
}

// Test Code
final class URLSessionHTTPClientTests: XCTestCase {

    func test_get_createsDataTaskWithURL() {
        let url = URL(string: "https://a-url.com")!
        let session = URLSessionSpy()
        session.stub(url: url)
        
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(url) { _ in }
        
        XCTAssertEqual(session.requestedURLs, [url])
    }
    
    func test_get_resumesDataTaskWithURL() {
        let url = URL(string: "https://a-url.com")!
        let session = URLSessionSpy()
        let dataTask = URLSesssionDataTaskSpy()
        
        session.stub(url: url, dataTask: dataTask)
        
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(url) { _ in }
        
        XCTAssertEqual(dataTask.resumeCount, 1)
    }
    
    func test_get_deliversErrorOnFailureResult() {
        let url = URL(string: "https://a-url.com")!
        let session = URLSessionSpy()
        let error = NSError(domain: "Test", code: 0)
        
        session.stub(url: url, error: error)
        
        let sut = URLSessionHTTPClient(session: session)
        
        let exp = expectation(description: "Waits for completion")
        
        sut.get(url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, error)
            default:
                XCTFail("completion result not as expected!")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
    }
    
    // Helpers
    
    class URLSessionSpy: URLSession {
        var requestedURLs = [URL]()
        private var stubs = [URL : Stub]()
        
        struct Stub {
            let task: URLSessionDataTask
            let error: Error?
        }
        
        func stub(url: URL, dataTask: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
            stubs[url] = Stub(task: dataTask, error: error)
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            requestedURLs.append(url)

            guard let stub = stubs[url] else {
                fatalError("no stub found for url \(url)!")
            }
            completionHandler(nil, nil, stub.error)
            return stub.task
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
