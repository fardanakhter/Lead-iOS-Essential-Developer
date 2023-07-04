//
//  RemoteLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 04/07/2023.
//

import Foundation
import XCTest
import EssentialFeed

class RemoteLoaderTest: XCTestCase {
    
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
    
    func test_load_doesNotInvokeCompletionWithResultAfterSutDeallocated() {
        let url = URL(string: "http://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteLoader? = RemoteLoader(url: url, httpClient: client)
        
        var capturedResults = [RemoteLoader.Result]()
        sut?.load() { result in
            capturedResults.append(result)
        }
        
        sut = nil
        client.complete(withError: anyError())
        client.complete(withStatusCode: 200, data: makeItemJSON([:]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(_ url: URL = URL(string: "https://a-url.com")!, file: StaticString = #file, line: UInt = #line) -> (RemoteLoader, HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteLoader(url: url, httpClient: client)
        
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
    
    private func expect(_ sut: RemoteLoader, toCompleteWith expectedResult: RemoteLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        let expectation = expectation(description: "Waiting for load() to complete")
        
        sut.load() { result in
            Self.compare(result, with: expectedResult, file: file, line: line)
            expectation.fulfill()
        }
        
        action()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    private static func compare(_ result: RemoteLoader.Result, with expectedResult: RemoteLoader.Result, file: StaticString = #file, line: UInt = #line) {
        switch (result, expectedResult)  {
        case (.success(let loadedItems), .success(let expectedItems)):
            XCTAssertEqual(loadedItems, expectedItems, file: file, line: line)
        
        case (.failure(let loadedError as RemoteLoader.Error), .failure(let expectedError as RemoteLoader.Error)):
            XCTAssertEqual(loadedError, expectedError, file: file, line: line)
        
        default:
            XCTFail("Loaded Result: \(result) not as Expected: \(expectedResult)", file: file, line: line)
        }
    }
    
    private func failure(_ error: RemoteLoader.Error) -> RemoteLoader.Result {
        return .failure(error)
    }
    
}
