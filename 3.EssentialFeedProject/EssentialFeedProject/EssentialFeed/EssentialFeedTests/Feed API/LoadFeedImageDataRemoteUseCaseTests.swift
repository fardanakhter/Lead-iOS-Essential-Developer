//
//  LoadFeedImageDataRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 19/05/2023.
//

import XCTest

class RemoteFeedImageDataLoader {
}

class LoadFeedImageDataRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotLoadImage() {
        let client = HTTPClientSpy()
        let _ = RemoteFeedImageDataLoader()
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    class HTTPClientSpy {
        var requestedURLs = [URL]()
    }
    
}
