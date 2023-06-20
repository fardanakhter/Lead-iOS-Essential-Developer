//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 25/03/2023.
//

import Foundation

internal final class FeedItemMapper {
    
    private struct Root: Decodable {
        private let items: [Item]
        
        private struct Item: Decodable {
            let id: UUID
            let description: String?
            let location: String?
            let image: URL
        }
        
        var feed: [FeedImage] {
            items.map{ FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image) }
        }
    }
    
    private static let OK_200: Int = 200
    
    internal static func map(from data: Data, and response: HTTPURLResponse) throws -> [FeedImage] {
        guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data)
        else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.feed
    }
}
