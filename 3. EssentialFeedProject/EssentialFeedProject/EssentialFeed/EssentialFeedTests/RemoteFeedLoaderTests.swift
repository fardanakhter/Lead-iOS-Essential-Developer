//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 21/03/2023.
//

import XCTest

class RemoteFeedLoader {
    let httpClient: HTTPClient
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    func load() {
        self.httpClient.get(URL(string: "https://a-test-url.com"))
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
        let client = HTTPClientSkpy()
        let _ = RemoteFeedLoader(httpClient: client)
        
        XCTAssertNil(client.requestedURL)
    }

    func test_load_requestsDataFromURL() {
        let client = HTTPClientSkpy()
        let sut = RemoteFeedLoader(httpClient: client)
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
    
}
