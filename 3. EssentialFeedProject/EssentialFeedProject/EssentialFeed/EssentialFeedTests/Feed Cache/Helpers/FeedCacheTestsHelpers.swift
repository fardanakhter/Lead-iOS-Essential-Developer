//
//  FeedCacheTestsHelpers.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 05/04/2023.
//

import Foundation
import EssentialFeed

internal func uniqueImage() -> FeedImage {
    return FeedImage(id: UUID(), description: nil, location: nil, url: anyURL())
}

internal func uniqueImageFeeds() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let feeds = [uniqueImage(), uniqueImage()]
    let localFeeds = feeds.map {
        LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
    }
    return (feeds, localFeeds)
}

internal extension Date {
    func addingDay(_ day: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: day, to: self)!
    }
    
    func addingSeconds(_ timeInterval: TimeInterval) -> Date {
        return self + timeInterval
    }
}
