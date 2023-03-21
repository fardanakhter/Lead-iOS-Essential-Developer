//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 21/03/2023.
//

import XCTest

class RemoteFeedLoader {
    let url: URL
    let httpClient: HTTPClient
    
    init(url: URL, httpClient: HTTPClient) {
        self.url = url
        self.httpClient = httpClient
    }
    
    func load() {
        self.httpClient.get(url)
    }
}

protocol HTTPClient {
    func get(_ url: URL?)
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertNil(client.requestedURL)
    }

    func test_load_requestsDataFromURL() {
        let (sut, client) = makeSUT()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> (RemoteFeedLoader, HTTPClientSkpy){
        let url = URL(string: "https://a-given-url.com")!
        let client = HTTPClientSkpy()
        let sut = RemoteFeedLoader(url: url, httpClient: client)
        return (sut, client)
    }
    
    class HTTPClientSkpy: HTTPClient {
        var requestedURL: URL?
        
        func get(_ url: URL?) {
            requestedURL = url
        }
    }
}
