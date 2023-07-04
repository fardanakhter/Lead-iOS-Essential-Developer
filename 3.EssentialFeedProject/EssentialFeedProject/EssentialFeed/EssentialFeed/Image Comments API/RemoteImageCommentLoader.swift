//
//  RemoteImageCommentLoader.swift
//  EssentialFeedAPI
//
//  Created by Fardan Akhter on 19/06/2023.
//

import Foundation

public typealias RemoteImageCommentLoader = RemoteLoader<[ImageComment]>

extension RemoteImageCommentLoader {
    public convenience init(url: URL, httpClient: HTTPClient) {
        self.init(url: url, httpClient: httpClient, mapper: ImageCommentMapper.map)
    }
}
