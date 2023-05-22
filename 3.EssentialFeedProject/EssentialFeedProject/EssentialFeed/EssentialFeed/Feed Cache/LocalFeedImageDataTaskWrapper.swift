//
//  LocalFeedImageDataTaskWrapper.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 22/05/2023.
//

import Foundation

final class LocalFeedImageDataTaskWrapper: FeedImageDataLoaderTask {
    private let completion: (LocalFeedImageDataLoader.Result) -> Void
    
    init(_ completion: @escaping (LocalFeedImageDataLoader.Result) -> Void) {
        self.completion = completion
    }
    
    func completeWith(_ result: LocalFeedImageDataLoader.Result) {
        self.completion(result)
    }
    
    func cancel() {}
}
