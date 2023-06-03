//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 27/05/2023.
//

import Foundation

public protocol FeedCache {
    typealias SaveResult = Result<Void,Error>
    func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void)
}
