//
//  FeedImageDataStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 22/05/2023.
//

import Foundation
import EssentialFeedCache

class FeedImageDataStoreSpy: FeedImageDataStore {
    private(set) var receivedMessages = [Message]()
    private var completionsForInsertion = [FeedImageDataStore.InsertCompletion]()
    private var completionsForLoad = [FeedImageDataStore.LoadCompletion]()
    
    enum Message: Equatable {
        case insert(data: Data, for: URL)
        case load(dataForUrl: URL)
    }
    
    func insert(_ cache: Data, with url: URL, completion: @escaping FeedImageDataStore.InsertCompletion) {
        receivedMessages.append(.insert(data: cache, for: url))
        completionsForInsertion.append(completion)
    }
    
    func loadCache(with url: URL, completion: @escaping FeedImageDataStore.LoadCompletion) {
        receivedMessages.append(.load(dataForUrl: url))
        completionsForLoad.append(completion)
    }
    
    // MARK: - Helpers
    
    func completeInsertion(withError error: Error, at index: Int = 0) {
        completionsForInsertion[index](.failure(error))
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        completionsForInsertion[index](.success(()))
    }
    
    func completeLoad(withError error: Error, at index: Int = 0) {
        completionsForLoad[index](.failure(error))
    }
    
    func completeLoadWithEmptyCache(at index: Int = 0) {
        completionsForLoad[index](.success(nil))
    }
    
    func completeLoad(withCache data: Data, at index: Int = 0) {
        completionsForLoad[index](.success(data))
    }

}
