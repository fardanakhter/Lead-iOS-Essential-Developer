//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 01/04/2023.
//

import Foundation

public protocol FeedStore {
    typealias DeleteCompletion = (Error?) -> Void
    typealias InsertCompletion = (Error?) -> Void
    
    func deleteFeedCache(completion: @escaping DeleteCompletion)
    func insertFeedCache(with items: [LocalFeedItem], and timestamp: Date, completion: @escaping InsertCompletion)
}
