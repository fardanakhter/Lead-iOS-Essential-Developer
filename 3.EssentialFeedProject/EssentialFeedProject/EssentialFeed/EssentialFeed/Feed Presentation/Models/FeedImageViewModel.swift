//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 14/05/2023.
//

import Foundation

public struct FeedImageViewModel<Image> {
    public let description: String?
    public let location: String?
    public let image: Image?
    public let shouldRetry: Bool
    
    public var hasLocation: Bool {
        location != nil
    }
    
    public init(description: String?, location: String?, image: Image?, shouldRetry: Bool) {
        self.description = description
        self.location = location
        self.image = image
        self.shouldRetry = shouldRetry
    }
}
