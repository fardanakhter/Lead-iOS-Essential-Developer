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

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}

extension Date {
    func addingSeconds(_ timeInterval: TimeInterval) -> Date {
        return self + timeInterval
    }
    
    func addingMinutes(_ minutes: Int, calendar: Calendar = .current) -> Date {
        return calendar.date(byAdding: .minute, value: minutes, to: self)!
    }
    
    func addingDay(_ day: Int, calendar: Calendar = .current) -> Date {
        return calendar.date(byAdding: .day, value: day, to: self)!
    }
}
