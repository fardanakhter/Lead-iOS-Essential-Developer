//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 25/03/2023.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    func get(_ url: URL, completion: @escaping (HTTPClient.Result) -> Void)
}
