//
//  LoadImageCommentRemoteUseCaseTests.swift
//  EssentialFeedAPITests
//
//  Created by Fardan Akhter on 19/06/2023.
//

import Foundation
import XCTest
import EssentialFeed

class ImageCommentMapperTests: XCTestCase {
    
    func test_map_throwsErrorOnNon2xxResponse() throws {
        let statusCodes = [199, 150, 400, 500, 600]
        try statusCodes.forEach { code in
            XCTAssertThrowsError(
                try ImageCommentMapper.map(from: makeItemJSON([:]), and: HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_throwsErrorOn2xxResponseWhenInvalidJSON() throws {
        let invalidData = "Invalid Json".data(using: .utf8)!
        let statusCodes = [200, 210, 250, 270, 299]
        try statusCodes.forEach { code in
            XCTAssertThrowsError(
                try ImageCommentMapper.map(from: invalidData, and: HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_deliversNoItemOn2xxResponseWithEmptyJSONList() throws {
        let emptyItemList: [[String: Any]] = []
        let emptyJsonList = makeItemJSON(["record" : emptyItemList])
        
        let statusCodes = [200, 210, 250, 270, 299]
        try statusCodes.forEach { code in
            let result = try ImageCommentMapper.map(from: emptyJsonList, and: HTTPURLResponse(statusCode: code))
            XCTAssertEqual(result, [])
        }
    }
    
    func test_map_deliversItemsOn2xxResponseWithJSONList() throws {
        let (item01, item01JSON) = makeItem(id: UUID(),
                                            message: "a message",
                                            username: "a username",
                                            createdAt: (Date(timeIntervalSince1970: 1687152540), "2023-06-19T05:29:00.000Z"))
        
        let (item02, item02JSON) = makeItem(id: UUID(),
                                            message: "another message",
                                            username: "another username",
                                            createdAt: (Date(timeIntervalSince1970: 1687152540), "2023-06-19T05:29:00.000Z"))
        let itemsData = makeItemJSON(["record" : [item01JSON, item02JSON]])
        
        let statusCodes = [200, 210, 250, 270, 299]
        try statusCodes.forEach { code in
            let result = try ImageCommentMapper.map(from: itemsData, and: HTTPURLResponse(statusCode: code))
            XCTAssertEqual(result, [item01, item02])
        }
    }
    
    // MARK: - Helpers
    
    private func makeItem(id: UUID, message: String, username: String, createdAt: (data: Date, iso8601String: String)) -> (model: ImageComment, json: [String : Any]) {
        
        let item = ImageComment(id: id, message: message, createdAt: createdAt.data, username: username)
        
        let itemJSON: [String : Any] = ["id": id.uuidString,
                                        "message": message,
                                        "created_at": createdAt.iso8601String,
                                        "author": ["username" : username]]
        
        return (item, itemJSON)
    }
    
    private func makeItemJSON(_ items: [String : Any]) -> Data {
        return try! JSONSerialization.data(withJSONObject: items)
    }
}
