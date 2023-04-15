//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 13/04/2023.
//

import Foundation

extension CoreDataFeedStore: FeedStore {
    public func loadFeedCache(completion: @escaping LoadCompletion) {
        perform { context in
            do {
                guard let cache = try ManagedFeedCache.find(in: context) else {
                    return completion(.success(.none))
                }
                completion(.success(CachedFeed(feed: cache.localFeed, timestamp: cache.timestamp)))
            }
            catch(let error) {
                completion(.failure(error))
            }
        }
    }
   
    public func insertFeedCache(with feed: [LocalFeedImage], and timestamp: Date, completion: @escaping InsertCompletion) {
        perform { context in
            do {
                let newInstance = try ManagedFeedCache.newUniqueInstance(in: context)
                newInstance.timestamp = timestamp
                newInstance.feed = ManagedFeedImage.images(from: feed, in: context)
                try context.save()
                completion(.success(()))
            }
            catch(let error) {
                completion(.failure(error))
            }
        }
    }
    
    public func deleteFeedCache(completion: @escaping DeleteCompletion) {
        perform { context in
            do {
                try ManagedFeedCache.find(in: context).map(context.delete).map(context.save)
                completion (.success(()))
            }
            catch(let error) {
                completion(.failure(error))
            }
        }
    }
}
