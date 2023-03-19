//
//  FeedlLoader.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 19/03/2023.
//

import Foundation

enum LoadFeedResult {
    case success(FeedItem)
    case error(Error)
}

protocol FeedLoader {
    func loadFeed(completion: @escaping (LoadFeedResult) -> Void)
}
