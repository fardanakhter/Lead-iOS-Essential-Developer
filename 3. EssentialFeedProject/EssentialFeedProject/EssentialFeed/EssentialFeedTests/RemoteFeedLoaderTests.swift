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

class HTTPClientSkpy: HTTPClient {
    var requestedURL: URL?
    
    func get(_ url: URL?) {
        requestedURL = url
    }
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let client = HTTPClientSkpy()
        let _ = RemoteFeedLoader(url: url, httpClient: client)
        
        XCTAssertNil(client.requestedURL)
    }

    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let client = HTTPClientSkpy()
        let sut = RemoteFeedLoader(url: url, httpClient: client)
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
    
}
