//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 23/03/2023.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
   
    private let url: URL
    private let httpClient: HTTPClient
    
    public enum Error: Swift.Error {
        case noConnection
        case invalidData
    }
    
    public typealias Result = LoadFeedResult
    
    public init(url: URL, httpClient: HTTPClient) {
        self.url = url
        self.httpClient = httpClient
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        self.httpClient.get(url) { [weak self] result in
            guard let _ = self else { return }
            
            switch result {
            case let .success(data, response):
                do {
                    let items = try FeedItemMapper.map(from: data, and: response)
                    completion(.success(items.toModels()))
                }
                catch(let error) {
                    completion(.failure(error))
                }
            case .failure:
                completion(.failure(Error.noConnection))
            }
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedItem] {
        map({
            FeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.image)
        })
    }
}
