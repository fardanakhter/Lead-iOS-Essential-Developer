//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 21/03/2023.
//

import Foundation
import XCTest
import EssentialFeed

class LoadFeedRemoteUseCaseTests: XCTestCase {
        
    func test_load_deliversErrorOnNon200Response() {
        let (sut, client) = makeSUT()
        
        let statusCodes = [199, 201, 400, 500, 600]
        statusCodes.enumerated().forEach { index, code in
            
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                client.complete(withStatusCode: code, data: makeItemJSON([:]), at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200ResponseWhenInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let invalidJsonData = "Invalid Json".data(using: .utf8)!
            client.complete(withStatusCode: 200, data: invalidJsonData)
        })
    }
    
    func test_load_deliversNoItemOn200ResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .success([]), when: {
            let emptyItemList: [[String: Any]] = [] 
            let emptyJsonList = makeItemJSON(["items" : emptyItemList])
            client.complete(withStatusCode: 200, data: emptyJsonList)
        })
    }
    
    func test_load_deliversItemsOn200ResponseWithJSONList() {
        let (sut, client) = makeSUT()
        
        let (item01, item01JSON) = makeItem(id: UUID(),
                                            description: "some description",
                                            location: "some location",
                                            imageURL: URL(string: "https://a-url.com")!)
        
        let (item02, item02JSON) = makeItem(id: UUID(),
                                            imageURL: URL(string: "https://a-url.com")!)
        
        expect(sut, toCompleteWith: .success([item01, item02]), when: {
            let itemsData = makeItemJSON(["items" : [item01JSON, item02JSON]])
            client.complete(withStatusCode: 200, data: itemsData)
        })
    }
    
    // MARK: - Helpers
    
    private func makeSUT(_ url: URL = URL(string: "https://a-url.com")!, file: StaticString = #file, line: UInt = #line) -> (RemoteFeedLoader, HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, httpClient: client)
        
        trackMemoryLeak(client)
        trackMemoryLeak(sut)
        
        return (sut, client)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedImage, json: [String : Any]) {
        
        let item = FeedImage(id: id,
                            description: description,
                            location: location,
                            url: imageURL)
        
        let itemJSON = ["id": item.id.uuidString,
                        "description": item.description,
                        "location": item.location,
                        "image": item.url.absoluteString
        ].compactMapValues{ $0 }
        
        return (item, itemJSON)
    }
    
    private func makeItemJSON(_ items: [String : Any]) -> Data {
        return try! JSONSerialization.data(withJSONObject: items)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWith expectedResult: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        let expectation = expectation(description: "Waiting for load() to complete")
        
        sut.load() { result in
            Self.compare(result, with: expectedResult)
            expectation.fulfill()
        }
        
        action()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    private static func compare(_ result: RemoteFeedLoader.Result, with expectedResult: RemoteFeedLoader.Result, file: StaticString = #file, line: UInt = #line) {
        switch (result, expectedResult)  {
        case (.success(let loadedItems), .success(let expectedItems)):
            XCTAssertEqual(loadedItems, expectedItems, file: file, line: line)
        
        case (.failure(let loadedError as RemoteFeedLoader.Error), .failure(let expectedError as RemoteFeedLoader.Error)):
            XCTAssertEqual(loadedError, expectedError, file: file, line: line)
        
        default:
            XCTFail("Loaded Result: \(result) not as Expected: \(expectedResult)", file: file, line: line)
        }
    }
    
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return .failure(error)
    }
    
}
