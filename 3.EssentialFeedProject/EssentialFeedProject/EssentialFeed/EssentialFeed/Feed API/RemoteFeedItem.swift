//
//  RemoteFeedITem.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 02/04/2023.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL //this key is as per API response body
}
