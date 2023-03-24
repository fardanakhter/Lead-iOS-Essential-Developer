//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 23/03/2023.
//

import Foundation

public enum HTTPClientResult {
    case success(HTTPURLResponse)
    case failure(Error)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let httpClient: HTTPClient
    
    public enum Error: Swift.Error {
        case noConnection
        case invalidData
    }
    
    public init(url: URL, httpClient: HTTPClient) {
        self.url = url
        self.httpClient = httpClient
    }
    
    public func load(completion: @escaping (RemoteFeedLoader.Error) -> Void = {_ in}) {
        self.httpClient.get(url) { result  in
            
            switch result {
            case .success(let response):
                if response.statusCode != 200 {
                    completion(.invalidData)
                }
                
            case .failure:
                completion(.noConnection)
            }
        }
    }
}

public protocol HTTPClient {
    func get(_ url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
