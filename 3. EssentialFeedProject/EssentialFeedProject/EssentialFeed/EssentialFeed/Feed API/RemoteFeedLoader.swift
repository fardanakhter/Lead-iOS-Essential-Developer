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
                if let items = try? FeedItemMapper.map(with: data, response: response) {
                    completion(.success(items))
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

private class FeedItemMapper {
    
    private struct Root: Decodable {
        let items: [Item]
    }
    
    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL //this key is as per API response body
        
        var item: FeedItem {
            .init(id: id, description: description, location: location, imageURL: image)
        }
    }
    
    static func map(with data: Data, response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == 200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return try JSONDecoder().decode(Root.self, from: data).items.map{ $0.item }
    }
}
