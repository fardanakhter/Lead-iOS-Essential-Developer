//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 21/03/2023.
//

import Foundation
import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url)
        
        sut.load() { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url)
        
        sut.load() { _ in }
        sut.load() { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithError: .noConnection, when: {
            let clientError = NSError(domain: "Test Error", code: 0)
            client.complete(withError: clientError)
        })
    }
    
    func test_load_deliversErrorOnNon200Response() {
        let (sut, client) = makeSUT()
        
        let statusCodes = [199, 201, 400, 500, 600]
        statusCodes.enumerated().forEach { index, code in
            
            expect(sut, toCompleteWithError: .invalidData, when: {
                client.complete(withStatusCode: code, at: index)
            })
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(_ url: URL = URL(string: "https://a-url.com")!) -> (RemoteFeedLoader, HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, httpClient: client)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWithError error: RemoteFeedLoader.Error, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load() { error in
            capturedErrors.append(error)
        }
        
        action()
        
        XCTAssertEqual(capturedErrors, [error], file: file, line: line)
    }
    
    class HTTPClientSpy: HTTPClient {
        
        var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URL] {
            messages.map{ $0.url }
        }
        
        func get(_ url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        // MARK: - Helper
        
        func complete(withError error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, at index: Int = 0) {
            let response = HTTPURLResponse(url: messages[index].url,
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            messages[index].completion(.success(response))
        }
    }
    
    
}
