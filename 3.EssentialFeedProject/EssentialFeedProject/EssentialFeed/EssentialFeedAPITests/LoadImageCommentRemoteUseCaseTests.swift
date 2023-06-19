//
//  LoadImageCommentRemoteUseCaseTests.swift
//  EssentialFeedAPITests
//
//  Created by Fardan Akhter on 19/06/2023.
//

import Foundation
import XCTest
import EssentialFeed
import EssentialFeedAPI

class LoadImageCommentRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url)
        
        sut.load() { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url)
        
        sut.load() { _ in }
        sut.load() { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.noConnection), when: {
            let clientError = NSError(domain: "Test Error", code: 0)
            client.complete(withError: clientError)
        })
    }
    
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
                                            description: "some description",
                                            location: "some location",
                                            imageURL: URL(string: "https://a-url.com")!)
        
        let (item02, item02JSON) = makeItem(id: UUID(),
                                            imageURL: URL(string: "https://a-url.com")!)
        
        let statusCodes = [200, 210, 250, 270, 299]
        statusCodes.enumerated().forEach { index, code in
            
            expect(sut, toCompleteWith: .success([item01, item02]), when: {
                let itemsData = makeItemJSON(["items" : [item01JSON, item02JSON]])
                client.complete(withStatusCode: code, data: itemsData, at: index)
            })
        }
    }
    
    func test_load_doesNotInvokeCompletionWithResultAfterSutDeallocated() {
        let url = URL(string: "http://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteImageCommentLoader? = RemoteImageCommentLoader(url: url, httpClient: client)
        
        var capturedResults = [RemoteImageCommentLoader.Result]()
        sut?.load() { result in
            capturedResults.append(result)
        }
        
        sut = nil
        [150, 190, 200, 250, 299].forEach {
            client.complete(withStatusCode: $0, data: makeItemJSON([:]))
        }
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(_ url: URL = URL(string: "https://a-url.com")!, file: StaticString = #file, line: UInt = #line) -> (RemoteImageCommentLoader, HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteImageCommentLoader(url: url, httpClient: client)
        
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
