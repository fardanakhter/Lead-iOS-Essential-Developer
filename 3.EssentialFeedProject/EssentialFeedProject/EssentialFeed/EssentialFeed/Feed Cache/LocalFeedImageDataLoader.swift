//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 22/05/2023.
//

import Foundation

public final class LocalFeedImageDataLoader {
    private let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
    
    public typealias Result = Swift.Result<Data,Error>
    
    public enum Error: Swift.Error {
        case notFound
        case unknown(Swift.Error)
    }
    
    public func load(_ url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask {
        let task = LocalFeedImageDataTaskWrapper(completion)
        store.loadCache(with: url) {[weak self] result in
            guard let _ = self else { return }
            task.completeWith(result
                .mapError { .unknown($0) }
                .flatMap { data in
                    data.map { .success($0) } ?? .failure(.notFound)
                }
            )
        }
        return task
    }
}
