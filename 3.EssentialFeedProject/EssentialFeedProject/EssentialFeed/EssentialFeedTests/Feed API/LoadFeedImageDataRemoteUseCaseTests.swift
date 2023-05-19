//
//  LoadFeedImageDataRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 19/05/2023.
//

import XCTest
import EssentialFeed

class RemoteFeedImageDataLoader {
    private let client: HTTPClient
    
    init(_ client: HTTPClient) {
        self.client = client
    }
    
    typealias Result = Swift.Result<Data,Error>
    
    func load(_ url: URL, completion: @escaping (Result) -> Void) {
        client.get(url) { _ in }
    }
}

class LoadFeedImageDataRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestImageUrl() {
        let client = HTTPClientSpy()
        let _ = RemoteFeedImageDataLoader(client)
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_load_requestsImageUrl() {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client)
        let imageUrl = anyURL()
        
        let _ = sut.load(imageUrl, completion: {_ in})
        
        XCTAssertEqual(client.requestedURLs, [imageUrl])
    }
    
    class HTTPClientSpy: HTTPClient {
        private(set) var requestedURLs = [URL]()
        
        func get(_ url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) {
            requestedURLs.append(url)
        }
    }
    
}
