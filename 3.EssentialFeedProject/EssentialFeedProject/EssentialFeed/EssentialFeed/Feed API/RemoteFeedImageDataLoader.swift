//
//  RemoteFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 20/05/2023.
//

import Foundation

public class RemoteFeedImageDataLoader {
    private let client: HTTPFeedImageLoaderClient
    
    public init(_ client: HTTPFeedImageLoaderClient) {
        self.client = client
    }
    
    public typealias Result = Swift.Result<Data, Error>
    
    public enum Error: Swift.Error {
        case invalidData
        case noConnection
    }
    
    public func load(_ url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask {
        let task = HTTPClientTaskWrapper(completion)
        
        task.wrapper = client.get(url) {[weak self] result in
            guard let _ = self else { return }
            
            task.complete(with: result
                .mapError {_ in .noConnection }
                .flatMap { (data, response) in
                    if response.isOK && !data.isEmpty {
                        return .success(data)
                    }
                    return .failure(.invalidData)
                }
            )
        }
        
        return task
    }
}
