//
//  HTTPClientTastWrapper.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 20/05/2023.
//

import Foundation

public protocol HTTPFeedImageLoaderClientTask {
    func cancel()
}

public protocol HTTPFeedImageLoaderClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    func get(_ url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPFeedImageLoaderClientTask
}

class HTTPClientTaskWrapper: FeedImageDataLoaderTask {
    private var completion: ((RemoteFeedImageDataLoader.Result) -> Void)?
    
    var wrapper: HTTPFeedImageLoaderClientTask?
    
    init(_ completion: @escaping (Result<Data, RemoteFeedImageDataLoader.Error>) -> Void) {
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
