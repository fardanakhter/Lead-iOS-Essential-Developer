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
    
    private class URLSessionTaskWrapper: HTTPClientTask {
        private let wrapper: URLSessionTask
        
        init(wrapper: URLSessionTask) {
            self.wrapper = wrapper
        }
        
        func cancel() {
            wrapper.cancel()
        }
    }
    
    public func get(_ url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        
        let dataTask = session.dataTask(with: url) { data, response, error in
            completion(Result(catching: {
                if let data, let response = response as? HTTPURLResponse {
                    return (data, response)
                }
                else if let error {
                    throw error
                }
                else {
                    throw UnexpectedError()
                }
            }))
        }
        dataTask.resume()
        
        return URLSessionTaskWrapper(wrapper: dataTask)
    }
}
