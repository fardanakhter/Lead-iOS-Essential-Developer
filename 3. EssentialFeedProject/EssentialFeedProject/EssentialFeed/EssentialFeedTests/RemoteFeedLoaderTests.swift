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
        let url = URL(string: "https://a-given-url.com")!
        let (_, client) = makeSUT(url)
        
        XCTAssertNil(client.requestedURL)
    }

    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURL, url)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(_ url: URL) -> (RemoteFeedLoader, HTTPClientSkpy){
        let client = HTTPClientSkpy()
        let sut = RemoteFeedLoader(url: url, httpClient: client)
        return (sut, client)
    }
    
    class HTTPClientSkpy: HTTPClient {
        var requestedURL: URL?
        
        func get(_ url: URL) {
            requestedURL = url
        }
    }
}
