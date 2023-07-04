//
//  RemoteLoader.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 04/07/2023.
//

import Foundation

public final class RemoteLoader<Resource> {
    
    private let url: URL
    private let httpClient: HTTPClient
    private let mapper: Mapper
    
    public enum Error: Swift.Error {
        case noConnection
        case invalidData
    }
    
    public typealias Result = Swift.Result<Resource, Error>
    public typealias Mapper = (Data, HTTPURLResponse) throws -> Resource
        
    public init(url: URL, httpClient: HTTPClient, mapper: @escaping Mapper) {
        self.url = url
        self.httpClient = httpClient
        self.mapper = mapper
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        let _ = self.httpClient.get(url) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case let .success((data, response)):
                completion(map(data: data, response: response))
            case .failure:
                completion(.failure(Error.noConnection))
            }
        }
    }
    
    private func map(data: Data, response: HTTPURLResponse) -> Result {
        do {
            return .success(try mapper(data, response))
        }
        catch {
            return .failure(Error.invalidData)
        }
    }
}
