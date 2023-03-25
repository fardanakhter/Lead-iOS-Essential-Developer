//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 23/03/2023.
//

import Foundation

public final class RemoteFeedLoader {
   
    private let url: URL
    private let httpClient: HTTPClient
    
    public enum Error: Swift.Error {
        case noConnection
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url: URL, httpClient: HTTPClient) {
        self.url = url
        self.httpClient = httpClient
    }
    
    public func load(completion: @escaping (RemoteFeedLoader.Result) -> Void) {
        self.httpClient.get(url) { result  in
            
            switch result {
            case let .success(data, response):
                completion(self.map(from: data, and: response))
            case .failure:
                completion(.failure(.noConnection))
            }
        }
    }
    
    private func map(from data: Data, and response: HTTPURLResponse) -> Result {
        if let items = try? FeedItemMapper.map(with: data, response: response) {
            return .success(items)
        }
        else {
            return .failure(.invalidData)
        }
    }
}
