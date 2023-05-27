//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 27/05/2023.
//

import Foundation

public protocol FeedImageDataCache {
    typealias SaveResult = Swift.Result<Void, Error>
    
    func save(_ cache: Data, with url: URL, completion: @escaping (SaveResult) -> Void)
}
