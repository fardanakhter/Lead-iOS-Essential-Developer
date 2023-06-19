//
//  RemoteImageCommentLoader.swift
//  EssentialFeedAPI
//
//  Created by Fardan Akhter on 19/06/2023.
//

import Foundation
import EssentialFeed

public final class RemoteImageCommentLoader: FeedLoader {
    private let url: URL
    private let httpClient: HTTPClient
    
    public enum Error: Swift.Error {
        case noConnection
        case invalidData
    }
    
    public typealias Result = FeedLoader.Result
    
    public init(url: URL, httpClient: HTTPClient) {
        self.url = url
        self.httpClient = httpClient
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        let _ = self.httpClient.get(url) { [weak self] result in
            guard let _ = self else { return }
            
            switch result {
            case let .success((data, response)):
                completion(RemoteImageCommentLoader.map(data: data, response: response))
            case .failure:
                completion(.failure(Error.noConnection))
            }
        }
    }
    
    private static func map(data: Data, response: HTTPURLResponse) -> Result {
        do {
            let items = try ImageCommentMapper.map(from: data, and: response)
            return .success(items.toModels())
        }
        catch(let error) {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedImage] {
        map({
            FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image)
        })
    }
}

