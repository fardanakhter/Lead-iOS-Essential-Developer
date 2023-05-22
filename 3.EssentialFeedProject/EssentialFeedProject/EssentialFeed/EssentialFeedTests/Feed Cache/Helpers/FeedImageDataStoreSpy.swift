//
//  FeedImageDataStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 22/05/2023.
//

import Foundation
import EssentialFeed

class FeedImageDataStoreSpy: FeedImageDataStore {
    private var messages = [(url: URL, completion: LoadCompletion)]()
    
    var requestedURLs: [URL] {
        messages.map { $0.url }
    }
    
    func insert(cache: Data, with url: URL, completion: @escaping InsertCompletion) {
    }
    
    func loadCache(with url: URL, completion: @escaping LoadCompletion) {
        messages.append((url, completion))
    }
    
    func completeLoad(withError error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func completeLoadWithEmptyCache(at index: Int = 0) {
        messages[index].completion(.success(nil))
    }
    
    func completeLoad(withCache data: Data, at index: Int = 0) {
        messages[index].completion(.success(data))
    }
    
}
