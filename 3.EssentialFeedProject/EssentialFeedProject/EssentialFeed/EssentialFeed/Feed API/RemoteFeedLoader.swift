//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 23/03/2023.
//

import Foundation

public typealias RemoteFeedLoader = RemoteLoader<[FeedImage]>

extension RemoteFeedLoader {
    public convenience init(url: URL, httpClient: HTTPClient) {
        self.init(url: url, httpClient: httpClient, mapper: FeedItemMapper.map)
    }
}
