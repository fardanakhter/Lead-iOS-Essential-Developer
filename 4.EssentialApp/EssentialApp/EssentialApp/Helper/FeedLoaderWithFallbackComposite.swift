//
//  FeedLoaderWithFallbackComposite.swift
//  EssentialApp
//
//  Created by Fardan Akhter on 24/05/2023.
//

import EssentialFeed

public class FeedLoaderWithFallbackComposite: FeedLoader {
    private let primaryLoader: FeedLoader
    private let fallbackLoader: FeedLoader
    
    public init(primary: FeedLoader, fallback: FeedLoader) {
        primaryLoader = primary
        fallbackLoader = fallback
    }
    
    public func load(completion: @escaping (Result<[FeedImage], Error>) -> Void) {
        primaryLoader.load { [weak self] primaryResult in
            switch primaryResult {
            case let .success(primaryFeed):
                completion(.success(primaryFeed))
            case .failure:
                self?.fallbackLoader.load(completion: completion)
            }
        }
    }
}
