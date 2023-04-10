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
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func deleteFeedCache(completion: @escaping DeleteCompletion)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func insertFeedCache(with feed: [LocalFeedImage], and timestamp: Date, completion: @escaping InsertCompletion)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func loadFeedCache(completion: @escaping LoadCompletion)
}
