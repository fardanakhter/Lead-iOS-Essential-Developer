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
    
    private struct UnexpectedError: Error {}
    
    func get(_ url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        let dataTask = session.dataTask(with: url) { data, response, error in
            if let error {
                completion(.failure(error))
            }
            else {
                completion(.failure(UnexpectedError()))
            }
        }
        dataTask.resume()
    }
}

// Test Code
final class URLSessionHTTPClientTests: XCTestCase {
    
    override class func setUp() {
        URLProtocolStub.startIntercepting()
    }
    
    override class func tearDown() {
        URLProtocolStub.stopIntercepting()
    }
    
    func test_get_failsOnErrorValue() {
        let requestedError = anyError()
        let receivedError = resultErrorFor(data: nil, response: nil, error: requestedError)
        
        XCTAssertNotNil(receivedError)
        XCTAssertEqual(receivedError!.domain, requestedError.domain, "Received error donot match Expected error.")
    }
    
    func test_get_failsOnAllInvalidCases() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyNonHttpUrlResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHttpUrlResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyNonHttpUrlResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHttpUrlResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyNonHttpUrlResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHttpUrlResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyNonHttpUrlResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHttpUrlResponse(), error: nil))
    }
    
    func test_get_performsGETRequestWithURL() {
        let url = anyURL()
        
        let exp = expectation(description: "Waits for completion")

        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }

        makeSUT().get(url) { _ in }

        wait(for: [exp], timeout: 1.0)
    }
    
    // Helpers
    
    private func anyURL() -> URL {
        URL(string: "https://any-url.com")!
    }
    
    private func anyError() -> NSError {
        NSError(domain: "Test", code: 0)
    }
    
    private func anyNonHttpUrlResponse() -> URLResponse {
        URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyHttpUrlResponse() -> HTTPURLResponse {
        HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func anyData() -> Data {
        Data("any data".utf8)
    }
    
    private func makeSUT() -> HTTPClient {
        URLSessionHTTPClient()
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: NSError?, file: StaticString = #file, line: UInt = #line) -> NSError? {
        URLProtocolStub.stub(data: data, response: response, error: error)
        
        let exp = expectation(description: "Waits for completion")
        
        var receivedError: NSError?
        
        makeSUT().get(anyURL()) { result in
            switch result {
            case .failure(let error as NSError):
                receivedError = error
            default:
                XCTFail("completion result not as expected!", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
    
    class URLProtocolStub: URLProtocol {
        
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func observeRequest(_ closure: @escaping ((URLRequest) -> Void)) {
            requestObserver = closure
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {
            URLProtocolStub.stub = nil
            URLProtocolStub.requestObserver = nil
        }
        
        static func startIntercepting() {
            URLProtocol.registerClass(self)
        }
        
        static func stopIntercepting() {
            URLProtocol.unregisterClass(self)
            URLProtocolStub.stub = nil
            URLProtocolStub.requestObserver = nil
        }
    }
    
}
