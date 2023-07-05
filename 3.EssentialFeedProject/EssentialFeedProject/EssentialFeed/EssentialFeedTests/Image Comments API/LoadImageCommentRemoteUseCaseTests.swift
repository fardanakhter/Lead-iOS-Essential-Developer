//
//  LoadImageCommentRemoteUseCaseTests.swift
//  EssentialFeedAPITests
//
//  Created by Fardan Akhter on 19/06/2023.
//

import Foundation
import XCTest
import EssentialFeed

class LoadImageCommentRemoteUseCaseTests: XCTestCase {
    
    func test_load_deliversErrorOnNon2xxResponse() {
        let (sut, client) = makeSUT()
        
        let statusCodes = [199, 150, 400, 500, 600]
        statusCodes.enumerated().forEach { index, code in
            
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                client.complete(withStatusCode: code, data: makeItemJSON([:]), at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn2xxResponseWhenInvalidJSON() {
        let (sut, client) = makeSUT()
        
        let statusCodes = [200, 210, 250, 270, 299]
        statusCodes.enumerated().forEach { index, code in
            
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let invalidJsonData = "Invalid Json".data(using: .utf8)!
                client.complete(withStatusCode: code, data: invalidJsonData, at: index)
            })
        }
    }
    
    func test_load_deliversNoItemOn2xxResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        let statusCodes = [200, 210, 250, 270, 299]
        statusCodes.enumerated().forEach { index, code in
            
            expect(sut, toCompleteWith: .success([]), when: {
                let emptyItemList: [[String: Any]] = []
                let emptyJsonList = makeItemJSON(["items" : emptyItemList])
                client.complete(withStatusCode: code, data: emptyJsonList, at: index)
            })
        }
    }
    
    func test_load_deliversItemsOn2xxResponseWithJSONList() {
        let (sut, client) = makeSUT()
        
        let (item01, item01JSON) = makeItem(id: UUID(),
                                            message: "a message",
                                            username: "a username",
                                            createdAt: (Date(timeIntervalSince1970: 1687152540), "2023-06-19T05:29:00+00:00"))
        
        let (item02, item02JSON) = makeItem(id: UUID(),
                                            message: "another message",
                                            username: "another username",
                                            createdAt: (Date(timeIntervalSince1970: 1687152540), "2023-06-19T05:29:00+00:00"))
        
        let statusCodes = [200, 210, 250, 270, 299]
        statusCodes.enumerated().forEach { index, code in
            
            expect(sut, toCompleteWith: .success([item01, item02]), when: {
                let itemsData = makeItemJSON(["items" : [item01JSON, item02JSON]])
                client.complete(withStatusCode: code, data: itemsData, at: index)
            })
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(_ url: URL = URL(string: "https://a-url.com")!, file: StaticString = #file, line: UInt = #line) -> (RemoteImageCommentLoader, HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteImageCommentLoader(url: url, httpClient: client)
        
        trackMemoryLeak(client)
        trackMemoryLeak(sut)
        
        return (sut, client)
    }
    
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
    
    private func expect(_ sut: RemoteImageCommentLoader, toCompleteWith expectedResult: RemoteImageCommentLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        let expectation = expectation(description: "Waiting for load() to complete")
        
        sut.load() { result in
            Self.compare(result, with: expectedResult, file: file, line: line)
            expectation.fulfill()
        }
        
        action()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    private static func compare(_ result: RemoteImageCommentLoader.Result, with expectedResult: RemoteImageCommentLoader.Result, file: StaticString = #file, line: UInt = #line) {
        switch (result, expectedResult)  {
        case (.success(let loadedItems), .success(let expectedItems)):
            XCTAssertEqual(loadedItems, expectedItems, file: file, line: line)
        
        case (.failure(let loadedError as RemoteImageCommentLoader.Error), .failure(let expectedError as RemoteImageCommentLoader.Error)):
            XCTAssertEqual(loadedError, expectedError, file: file, line: line)
        
        default:
            XCTFail("Loaded Result: \(result) not as Expected: \(expectedResult)", file: file, line: line)
        }
    }
    
    private func failure(_ error: RemoteImageCommentLoader.Error) -> RemoteImageCommentLoader.Result {
        return .failure(error)
    }
    
}
