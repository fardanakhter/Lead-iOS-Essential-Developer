//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 25/03/2023.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(_ url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
