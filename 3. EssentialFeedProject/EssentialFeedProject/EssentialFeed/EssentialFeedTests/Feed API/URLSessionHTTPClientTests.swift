//
//  HTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 26/03/2023.
//

import XCTest
import EssentialFeed

final class URLSessionHTTPClientTests: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        URLProtocolStub.startIntercepting()
    }
    
    override class func tearDown() {
        super.tearDown()
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
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyNonHttpUrlResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHttpUrlResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyNonHttpUrlResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHttpUrlResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyNonHttpUrlResponse(), error: nil))
    }
    
    func test_get_succeedsWithEmptyDataOnHttpUrlResponseWithNilDataValue () {
        let response = anyHttpUrlResponse()
        let receivedValues = resultSuccessFor(data: nil, response: response, error: nil)
        let emptyData = Data()
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(response.url, receivedValues?.response.url)
        XCTAssertEqual(response.statusCode, receivedValues?.response.statusCode)
    }
    
    func test_get_succeedsOnNonNilDataAndHttpUrlResponseValues() {
        let data = anyData()
        let response = anyHttpUrlResponse()
        
        let receivedValues = resultSuccessFor(data: data, response: response, error: nil)
        XCTAssertEqual(data, receivedValues?.data)
        XCTAssertEqual(response.url, receivedValues?.response.url)
        XCTAssertEqual(response.statusCode, receivedValues?.response.statusCode)
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
        let sut = URLSessionHTTPClient()
        trackMemoryLeak(sut)
        return sut
    }
    
    private func resultFor(data: Data?, response: URLResponse?, error: NSError?, file: StaticString = #file, line: UInt = #line) -> HTTPClientResult? {
        URLProtocolStub.stub(data: data, response: response, error: error)
        
        let exp = expectation(description: "Waits for completion")
        
        var receivedResult: HTTPClientResult?
        makeSUT().get(anyURL()) { result in
            receivedResult = result
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: NSError?, file: StaticString = #file, line: UInt = #line) -> NSError? {
        
        let result = resultFor(data: data, response: response, error: error)
        
        if case let .failure(receivedError as NSError) = result {
            return receivedError
        }
        else {
            XCTFail("Expected failure, got \(String(describing: result)) instead", file: file, line: line)
            return nil
        }
    }
    
    private func resultSuccessFor(data: Data?, response: URLResponse?, error: NSError?, file: StaticString = #file, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        
        let result = resultFor(data: data, response: response, error: error)
        
        if case let .success(receivedData, receivedResponse) = result {
            return (receivedData, receivedResponse)
        }
        else {
            XCTFail("Expected success, got \(String(describing: result)) instead", file: file, line: line)
            return nil
        }
    }
    
    class URLProtocolStub: URLProtocol {
        
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
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
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let observer = URLProtocolStub.requestObserver {
                client?.urlProtocolDidFinishLoading(self)
                observer(request)
                URLProtocolStub.requestObserver = nil
                return
            }
            
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
        
        override func stopLoading() {}
        
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
