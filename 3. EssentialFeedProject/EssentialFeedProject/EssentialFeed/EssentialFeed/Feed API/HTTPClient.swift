//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 25/03/2023.
//

import Foundation

public typealias HTTPClientResult = Result<(Data, HTTPURLResponse), Error>

public protocol HTTPClient {
    func get(_ url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
