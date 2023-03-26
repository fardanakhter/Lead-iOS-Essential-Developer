//
//  FeedlLoader.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 19/03/2023.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
