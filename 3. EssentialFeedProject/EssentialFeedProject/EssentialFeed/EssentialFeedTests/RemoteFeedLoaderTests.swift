//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 21/03/2023.
//

import XCTest

class RemoteFeedLoader {
}

class HTTPClient {
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let _ = RemoteFeedLoader()
        let client = HTTPClient()
        
        XCTAssertNil(client.requestedURL)
    }

}
