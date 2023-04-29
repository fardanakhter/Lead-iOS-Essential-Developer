//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 03/04/2023.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
    
    enum ReceivedMessages: Equatable {
        case deleteCacheFeed
        case insertCacheFeed([LocalFeedImage], Date)
        case loadImageFeed
    }
    
    private var completionsForDeletion = [DeleteCompletion]()
    private var completionsForInsertion = [InsertCompletion]()
    private var completionsForLoad = [LoadCompletion]()
    
    private(set) var receivedMessages = [ReceivedMessages]()
    
    func deleteFeedCache(completion: @escaping DeleteCompletion) {
        completionsForDeletion.append(completion)
        receivedMessages.append(.deleteCacheFeed)
    }
    
    func completeDeletion(withError error: NSError, at index: Int = 0) {
        completionsForDeletion[index](.failure(error))
    }
    
    func completeDeletionWithSuccess(at index: Int = 0) {
        completionsForDeletion[index](.success(()))
    }
    
    func insertFeedCache(with feed: [LocalFeedImage], and timestamp: Date, completion: @escaping InsertCompletion) {
        completionsForInsertion.append(completion)
        receivedMessages.append(.insertCacheFeed(feed, timestamp))
    }
    
    func completeInsertion(withError error: NSError, at index: Int = 0) {
        completionsForInsertion[index](.failure(error))
    }
    
    func completeInsertionWithSuccess(at index: Int = 0) {
        completionsForInsertion[index](.success(()))
    }
    
    func loadFeedCache(completion: @escaping LoadCompletion) {
        receivedMessages.append(.loadImageFeed)
        completionsForLoad.append(completion)
    }
    
    func completeLoad(withError error: NSError, at index: Int = 0) {
        completionsForLoad[index](.failure(error))
    }
    
    func completeLoadWithEmptyCache(at index: Int = 0) {
        completionsForLoad[index](.success(.none))
    }
    
    func completeLoad(with feed: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
        completionsForLoad[index](.success(CachedFeed(feed: feed, timestamp: timestamp)))
    }
    
}
