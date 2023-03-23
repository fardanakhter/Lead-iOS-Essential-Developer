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
    }
    
    public init(url: URL, httpClient: HTTPClient) {
        self.url = url
        self.httpClient = httpClient
    }
    
    public func load(completion: @escaping (RemoteFeedLoader.Error) -> Void = {_ in}) {
        self.httpClient.get(url) { error in
            if error != nil {
                completion(.noConnection)
            }
        }
    }
}

public protocol HTTPClient {
    func get(_ url: URL, completion: @escaping (Error?) -> Void)
}
