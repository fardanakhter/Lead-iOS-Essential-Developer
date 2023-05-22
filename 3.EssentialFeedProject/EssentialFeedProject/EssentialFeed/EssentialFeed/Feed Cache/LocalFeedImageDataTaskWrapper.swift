//
//  LocalFeedImageDataTaskWrapper.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 22/05/2023.
//

import Foundation

final class LocalFeedImageDataTaskWrapper: FeedImageDataLoaderTask {
    private let completion: (LocalFeedImageDataLoader.LoadResult) -> Void
    
    init(_ completion: @escaping (LocalFeedImageDataLoader.LoadResult) -> Void) {
        self.completion = completion
    }
    
    func completeWith(_ result: LocalFeedImageDataLoader.LoadResult) {
        self.completion(result)
    }
    
    func cancel() {}
}
