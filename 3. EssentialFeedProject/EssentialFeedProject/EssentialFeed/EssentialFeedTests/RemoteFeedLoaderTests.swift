//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 21/03/2023.
//

import Foundation
import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {

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
        
        expect(sut, toCompleteWith: .failure(.noConnection), when: {
            let clientError = NSError(domain: "Test Error", code: 0)
            client.complete(withError: clientError)
        })
    }
    
    func test_load_deliversErrorOnNon200Response() {
        let (sut, client) = makeSUT()
        
        let statusCodes = [199, 201, 400, 500, 600]
        statusCodes.enumerated().forEach { index, code in
            
            expect(sut, toCompleteWith: .failure(.invalidData), when: {
                client.complete(withStatusCode: code, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200ResponseWhenInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.invalidData), when: {
            let invalidJsonData = "Invalid Json".data(using: .utf8)!
            client.complete(withStatusCode: 200, data: invalidJsonData)
        })
    }
    
    func test_load_deliversNoItemOn200ResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .success([]), when: {
            let emptyJsonList = "{\"items\":[]}".data(using: .utf8)!
            client.complete(withStatusCode: 200, data: emptyJsonList)
        })
    }
    
    func test_load_deliversItemsOn200ResponseWithJSONList() {
        let (sut, client) = makeSUT()
        
        let item01 = FeedItem(id: UUID(),
                              description: "some description",
                              location: "some location",
                              imageURL: URL(string: "https://a-url.com")!)
        
        let item01JSON: [String : Any?] = ["id": item01.id.uuidString,
                                           "description": item01.description,
                                           "location": item01.location,
                                           "imageURL": item01.imageURL.absoluteString]
        
        let item02 = FeedItem(id: UUID(),
                              description: nil,
                              location: nil,
                              imageURL: URL(string: "https://a-url.com")!)
        
        let item02JSON: [String : Any?] = ["id": item02.id.uuidString,
                                           "description": item02.description,
                                           "location": item02.location,
                                           "imageURL": item02.imageURL.absoluteString]
        
        let itemsJSON = ["items" : [item01JSON, item02JSON]]
        
        expect(sut, toCompleteWith: .success([item01, item02]), when: {
            let itemsData = try! JSONSerialization.data(withJSONObject: itemsJSON)
            client.complete(withStatusCode: 200, data: itemsData)
        })
        
    }
    
    // MARK: - Helpers
    
    private func makeSUT(_ url: URL = URL(string: "https://a-url.com")!) -> (RemoteFeedLoader, HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, httpClient: client)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWith result: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load() { result in
            capturedResults.append(result)
        }
        
        action()
        
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
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
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(url: messages[index].url,
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }
    
    
}
