//
//  HTTPClientTastWrapper.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 20/05/2023.
//

import Foundation

class HTTPClientTaskWrapper: FeedImageDataLoaderTask {
    private var completion: ((RemoteFeedImageDataLoader.Result) -> Void)?
    
    var wrapper: HTTPClientTask?
    
    init(_ completion: @escaping (Result<Data, Error>) -> Void) {
        self.completion = completion
    }
    
    func complete(with result: RemoteFeedImageDataLoader.Result) {
        completion?(result)
    }
    
    func cancel() {
        wrapper?.cancel()
        wrapper = nil
        completion = nil
    }
}
