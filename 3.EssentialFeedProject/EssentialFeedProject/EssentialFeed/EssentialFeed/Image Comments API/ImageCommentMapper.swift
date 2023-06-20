//
//  ImageCommentMapper.swift
//  EssentialFeedAPI
//
//  Created by Fardan Akhter on 19/06/2023.
//

import Foundation

internal final class ImageCommentMapper {

    private struct Root: Decodable {
        private let items: [Item]

        private struct Item: Decodable {
            let id: UUID
            let message: String
            let createdAt: Date
            let author: Author
        }
        
        struct Author: Decodable {
            let username: String
        }
        
        var comments: [ImageComment] {
            items.map{ ImageComment(id: $0.id, message: $0.message, createdAt: $0.createdAt, username: $0.author.username) }
        }
    }
    
    internal static func map(from data: Data, and response: HTTPURLResponse) throws -> [ImageComment] {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        
        guard isOK(response), let root = try? decoder.decode(Root.self, from: data)
        else {
            throw RemoteImageCommentLoader.Error.invalidData
        }
        
        return root.comments
    }
    
    private static func isOK(_ response: HTTPURLResponse) -> Bool {
        return (200...299).contains(response.statusCode)
    }
}

