//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 23/03/2023.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

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
                if let feed = try? JSONDecoder().decode(Root.self, from: data),
                    response.statusCode == 200 {
                    completion(.success(feed.items))
                }
                else {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.noConnection))
            }
        }
    }
}

public protocol HTTPClient {
    func get(_ url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

private struct Root: Decodable {
    let items: [FeedItem]
}
