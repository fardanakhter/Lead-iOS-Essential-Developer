//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 28/03/2023.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnexpectedError: Error {}
    
    public func get(_ url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        let dataTask = session.dataTask(with: url) { data, response, error in
            if let data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            }
            else if let error {
                completion(.failure(error))
            }
            else {
                completion(.failure(UnexpectedError()))
            }
        }
        dataTask.resume()
    }
}
