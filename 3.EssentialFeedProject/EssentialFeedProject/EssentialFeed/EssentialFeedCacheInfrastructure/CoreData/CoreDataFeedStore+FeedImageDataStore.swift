//
//  CoreDataFeedStore+FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 22/05/2023.
//

import Foundation
import EssentialFeedCache

extension CoreDataFeedStore: FeedImageDataStore {
    public func insert(_ cache: Data, with url: URL, completion: @escaping FeedImageDataStore.InsertCompletion) {
        perform { context in
            completion(Result {
                try ManagedFeedImage.first(with: url, in: context)
                    .map { $0.data = cache }
                    .map(context.save)
            })
        }
    }
    
    public func loadCache(with url: URL, completion: @escaping FeedImageDataStore.LoadCompletion) {
        perform { context in
            completion(Result {
                try ManagedFeedImage.first(with: url, in: context)?.data
            })
        }
    }
}
