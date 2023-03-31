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
            let emptyJsonList = makeItemJSON(["items" : []])
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
    
    func test_load_doesNotInvokeCompletionWithResultAfterSutDeallocated() {
        let url = URL(string: "http://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, httpClient: client)
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load() { result in
            capturedResults.append(result)
        }
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemJSON([:]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(_ url: URL = URL(string: "https://a-url.com")!, file: StaticString = #file, line: UInt = #line) -> (RemoteFeedLoader, HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, httpClient: client)
        
        trackMemoryLeak(client)
        trackMemoryLeak(sut)
        
        return (sut, client)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedItem, json: [String : Any]) {
        
        let item = FeedItem(id: id,
                            description: description,
                            location: location,
                            imageURL: imageURL)
        
        let itemJSON = ["id": item.id.uuidString,
                        "description": item.description,
                        "location": item.location,
                        "image": item.imageURL.absoluteString]
        
            .reduce([String : Any]()) { acc, e in
                var newDict = acc
                if let value = e.value { newDict[e.key] = value }
                return newDict
            }
        
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
    
    class HTTPClientSpy: HTTPClient {
        
        var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URL] {
            messages.map{ $0.url }
        }
        
        func get(_ url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        // MARK: - Helper
        
        func complete(withError error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: messages[index].url,
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }
    
}