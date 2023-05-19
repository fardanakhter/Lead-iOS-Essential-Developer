//
//  FeedTestsHelpers.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 05/04/2023.
//

import Foundation
import EssentialFeed

internal func anyError() -> NSError {
    NSError(domain: "Test", code: 0)
}

internal func anyURL() -> URL {
    return URL(string: "https://any-url.com")!
}

internal func uniqueImage() -> FeedImage {
    return FeedImage(id: UUID(), description: nil, location: nil, url: anyURL())
}

internal func anyData() -> Data {
    return "any data".data(using: .utf8)!
}
