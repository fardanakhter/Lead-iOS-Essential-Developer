//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 19/03/2023.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
