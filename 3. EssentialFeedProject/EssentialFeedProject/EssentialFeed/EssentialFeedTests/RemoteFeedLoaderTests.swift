//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 21/03/2023.
//

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
        
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load() { error in
            capturedErrors.append(error)
        }
        
        let clientError = NSError(domain: "Test Error", code: 0)
        client.complete(withError: clientError)
        
        XCTAssertEqual(capturedErrors, [.noConnection])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(_ url: URL = URL(string: "https://a-url.com")!) -> (RemoteFeedLoader, HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, httpClient: client)
        return (sut, client)
    }
    
    class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URL]()
        var completions = [(Error?) -> Void]()
        
        func get(_ url: URL, completion: @escaping (Error?) -> Void) {
            completions.append(completion)
            requestedURLs.append(url)
        }
        
        // MARK: - Helper
        
        func complete(withError error: Error, at index: Int = 0) {
            completions[index](error)
        }
    }
}
