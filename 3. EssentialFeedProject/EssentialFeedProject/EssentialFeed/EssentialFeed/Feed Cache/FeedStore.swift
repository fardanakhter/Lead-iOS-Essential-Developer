//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 01/04/2023.
//

import Foundation

public enum LoadFeedCacheResult {
    case failure(Error)
    case found(feed: [LocalFeedImage], timestamp: Date)
    case empty
}

public protocol FeedStore {
    typealias DeleteCompletion = (Error?) -> Void
    typealias InsertCompletion = (Error?) -> Void
    typealias LoadCompletion = (LoadFeedCacheResult) -> Void
    
    func deleteFeedCache(completion: @escaping DeleteCompletion)
    func insertFeedCache(with feed: [LocalFeedImage], and timestamp: Date, completion: @escaping InsertCompletion)
    func loadFeedCache(completion: @escaping LoadCompletion)
}
