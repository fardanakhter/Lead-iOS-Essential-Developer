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
    
    init(session: URLSession = .shared) {
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
    
    func test_get_deliversErrorOnFailureResult() {
        URLProtocolStub.startIntercepting()
        let url = URL(string: "https://a-url.com")!
        let error = NSError(domain: "Test", code: 0)
        URLProtocolStub.stub(url: url, error: error)
        
        let sut = URLSessionHTTPClient()
        
        let exp = expectation(description: "Waits for completion")
        
        sut.get(url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError.domain, error.domain, "received error: \(receivedError) is not equal to expected error: \(error)")
            default:
                XCTFail("completion result not as expected!")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        URLProtocolStub.stopIntercepting()
    }
    
    // Helpers
    
    class URLProtocolStub: URLProtocol {
        
        private static var stubs = [URL : Stub]()
        
        struct Stub {
            let error: Error?
        }
        
        static func stub(url: URL, error: Error? = nil) {
            stubs[url] = Stub(error: error)
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            return URLProtocolStub.stubs[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else { return }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {
            URLProtocolStub.stubs = [:]
        }
        
        static func startIntercepting() {
            URLProtocol.registerClass(self)
        }
        
        static func stopIntercepting() {
            URLProtocol.unregisterClass(self)
            URLProtocolStub.stubs = [:]
        }
    }
    
}
