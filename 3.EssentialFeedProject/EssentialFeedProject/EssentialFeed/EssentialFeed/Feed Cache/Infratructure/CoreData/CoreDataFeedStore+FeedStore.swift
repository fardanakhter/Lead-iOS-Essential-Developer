//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 13/04/2023.
//

import Foundation

extension CoreDataFeedStore: FeedStore {
    public func loadFeedCache(completion: @escaping FeedStore.LoadCompletion) {
        perform { context in
            completion(Result(catching: {
                try ManagedFeedCache.find(in: context).map {
                    return CachedFeed(feed: $0.localFeed, timestamp: $0.timestamp)
                }
            }))
        }
    }
   
    public func insertFeedCache(with feed: [LocalFeedImage], and timestamp: Date, completion: @escaping FeedStore.InsertCompletion) {
        perform { context in
            completion(Result(catching: {
                let newInstance = try ManagedFeedCache.newUniqueInstance(in: context)
                newInstance.timestamp = timestamp
                newInstance.feed = ManagedFeedImage.images(from: feed, in: context)
                try context.save()
            }))
        }
    }
    
    public func deleteFeedCache(completion: @escaping FeedStore.DeleteCompletion) {
        perform { context in
            completion(Result(catching: {
                try ManagedFeedCache.find(in: context).map(context.delete).map(context.save)
            }))
        }
    }
}
