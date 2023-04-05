//
//  FeedTestsHelpers.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 05/04/2023.
//

import Foundation

internal func anyError() -> NSError {
    NSError(domain: "Test", code: 0)
}

internal func anyURL() -> URL {
    return URL(string: "https://any-url.com")!
}
