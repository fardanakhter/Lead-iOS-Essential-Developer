//
//  LoadFeedImageDataRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 19/05/2023.
//

import XCTest
import EssentialFeed

public protocol FeedImageDataLoaderTask {
    func cancel()
}

class HttpClientTaskWrapper: FeedImageDataLoaderTask {
    private var completion: ((RemoteFeedImageDataLoader.Result) -> Void)?
    
    init(_ completion: @escaping (Result<Data, RemoteFeedImageDataLoader.Error>) -> Void) {
        self.completion = completion
    }
    
    func complete(with result: RemoteFeedImageDataLoader.Result) {
        completion?(result)
    }
    
    func cancel() {
        completion = nil
    }
}

class RemoteFeedImageDataLoader {
    private let client: HTTPClient
    
    init(_ client: HTTPClient) {
        self.client = client
    }
    
    typealias Result = Swift.Result<Data, Error>
    
    enum Error: Swift.Error {
        case invalidData
        case noConnection
    }
    
    func load(_ url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask {
        let task = HttpClientTaskWrapper(completion)
        
        client.get(url) { result in
            switch result {
            case .success(_):
                task.complete(with: .failure(.invalidData))
                
            case .failure:
                task.complete(with: .failure(.noConnection))
            }
        }
        return task
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
            let noConnectionError = NSError(domain: "No Internet Connection", code: 0)
            client.complete(withError: noConnectionError)
        })
    }
    
    func test_load_doesNotDeliverErrorAfterCanceled() {
        let (sut, client) = makeSUT()
        let imageURL = anyURL()
        
        assertThatLoadDoesNotCompletesWhenCanceled(given: sut, when: {
            client.complete(withError: anyError())
        })
    }
    
    func test_load_doesNotDeliverResponseAfterCanceled() {
        let (sut, client) = makeSUT()
        let imageURL = anyURL()
        
        assertThatLoadDoesNotCompletesWhenCanceled(given: sut, when: {
            client.complete(withStatusCode: 200, data: "any data".data(using: .utf8)!)
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
    
    private func assertThatLoadDoesNotCompletesWhenCanceled(given sut: RemoteFeedImageDataLoader, when action: () -> Void) {
        var capturedResult = [RemoteFeedImageDataLoader.Result]()
        let task = sut.load(anyURL(), completion: { receivedResult in
            capturedResult.append(receivedResult)
        })
        task.cancel()
        
        action()

        XCTAssertEqual(capturedResult.isEmpty, true)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs: [URL] {
            messages.map{ $0.url }
        }
        
        private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        
        func get(_ url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            messages[index].completion(.success((data, response)))
        }
        
        func complete(withError error: NSError, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
    }
    
}
