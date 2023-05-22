//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 22/05/2023.
//

import Foundation

public protocol FeedImageDataSaver {
    typealias Result = Swift.Result<Void, Error>
    func save(_ cache: Data, with url: URL, completion: @escaping (Result) -> Void)
}

public final class LocalFeedImageDataLoader {
    private let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
}

extension LocalFeedImageDataLoader : FeedImageDataLoader {
    public typealias LoadResult = FeedImageDataLoader.Result
    
    public enum LoadError: Swift.Error {
        case notFound
        case unknown(Swift.Error)
    }
    
    public func load(_ url: URL, completion: @escaping (LoadResult) -> Void) -> FeedImageDataLoaderTask {
        let task = LocalFeedImageDataTaskWrapper(completion)
        store.loadCache(with: url) {[weak self] result in
            guard let _ = self else { return }
            task.completeWith(result
                .mapError { LoadError.unknown($0) }
                .flatMap { data in
                    data.map { .success($0) } ?? .failure(LoadError.notFound)
                }
            )
        }
        return task
    }
}

extension LocalFeedImageDataLoader : FeedImageDataSaver {
    public typealias SaveResult = FeedImageDataSaver.Result
    
    public enum SaveError: Swift.Error {
        case failed
    }
    
    public func save(_ cache: Data, with url: URL, completion: @escaping (SaveResult) -> Void) {
        store.insert(cache, with: url) {[weak self] result in
            guard let _ = self else { return }
            completion(result
                .mapError{ _ in SaveError.failed }
                .flatMap{ .success(()) }
            )
        }
    }
}
