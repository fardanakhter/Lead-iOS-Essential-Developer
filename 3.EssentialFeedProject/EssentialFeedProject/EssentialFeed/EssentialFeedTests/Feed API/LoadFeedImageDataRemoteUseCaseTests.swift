//
//  LoadFeedImageDataRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 19/05/2023.
//

import XCTest
import EssentialFeed

class RemoteFeedImageDataLoader {
    private let client: HTTPClient
    
    init(_ client: HTTPClient) {
        self.client = client
    }
    
    typealias Result = Swift.Result<Data,Error>
    
    enum Error: Swift.Error {
        case invalidData
        case noConnection
    }
    
    func load(_ url: URL, completion: @escaping (Result) -> Void) {
        client.get(url) { result in
            
            switch result {
            case .success(_):
                completion(.failure(.invalidData))
                
            case .failure:
                completion(.failure(.noConnection))
            }
        }
    }
}

class LoadFeedImageDataRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestImageUrl() {
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.requestedURLs, [])
    }

    func test_load_requestsImageUrl() {
        let (sut, client) = makeSUT()
        let imageUrl = anyURL()

        let _ = sut.load(imageUrl, completion: {_ in})
        
        XCTAssertEqual(client.requestedURLs, [imageUrl])
    }
    
    func test_load_deliversErrorOnInvalidImageData() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithError: .invalidData, when: {
            let invalidData = "invalid data".data(using: .utf8)!
            client.complete(withStatusCode: 200, data: invalidData)
        })
    }
    
    func test_load_deliversErrorOnNoInternetConnection() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithError: .noConnection, when: {
            client.complete(withError: NSError(domain: "No Internet Connection", code: 0))
        })
    }
    
    private func makeSUT() -> (RemoteFeedImageDataLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client)
        trackMemoryLeak(sut)
        trackMemoryLeak(client)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteFeedImageDataLoader, toCompleteWithError expectedError: RemoteFeedImageDataLoader.Error, when action: () -> Void) {
        
        let exp = expectation(description: "Waits for load() to complete")
        let _ = sut.load(anyURL(), completion: { result in
            switch result {
            case .failure(let receivedError):
                XCTAssertEqual(receivedError, expectedError)
            default:
                XCTFail("Loaded error not same as expected")
            }
            exp.fulfill()
        })
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    class HTTPClientSpy: HTTPClient {
        private(set) var requestedURLs = [URL]()
        private var messages = [(HTTPClient.Result) -> Void]()
        
        func get(_ url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            requestedURLs.append(url)
            messages.append(completion)
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            messages[index](.success((data, response)))
        }
        
        func complete(withError error: NSError, at index: Int = 0) {
            messages[index](.failure(error))
        }
    }
    
}
