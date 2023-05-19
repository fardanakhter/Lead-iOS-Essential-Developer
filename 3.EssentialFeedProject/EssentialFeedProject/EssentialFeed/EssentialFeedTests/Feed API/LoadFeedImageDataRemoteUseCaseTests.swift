//
//  LoadFeedImageDataRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 19/05/2023.
//

import XCTest
import EssentialFeed


protocol HTTPFeedImageLoaderClientTask {
    func cancel()
}

protocol HTTPFeedImageLoaderClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    func get(_ url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPFeedImageLoaderClientTask
}

public protocol FeedImageDataLoaderTask {
    func cancel()
}

class HTTPClientTaskWrapper: FeedImageDataLoaderTask {
    private var completion: ((RemoteFeedImageDataLoader.Result) -> Void)?
    
    var wrapper: HTTPFeedImageLoaderClientTask?
    
    init(_ completion: @escaping (Result<Data, RemoteFeedImageDataLoader.Error>) -> Void) {
        self.completion = completion
    }
    
    func complete(with result: RemoteFeedImageDataLoader.Result) {
        completion?(result)
    }
    
    func cancel() {
        wrapper?.cancel()
        wrapper = nil
        completion = nil
    }
}

class RemoteFeedImageDataLoader {
    private let client: HTTPFeedImageLoaderClient
    
    init(_ client: HTTPFeedImageLoaderClient) {
        self.client = client
    }
    
    typealias Result = Swift.Result<Data, Error>
    
    enum Error: Swift.Error {
        case invalidData
        case noConnection
    }
    
    func load(_ url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask {
        let task = HTTPClientTaskWrapper(completion)
        
        task.wrapper = client.get(url) { result in
            switch result {
            case let .success((data, response)):
                if response.isOK && !data.isEmpty {
                    task.complete(with: .success(data))
                }
                else {
                    task.complete(with: .failure(.invalidData))
                }
                
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
            let invalidData = Data()
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
            client.complete(withStatusCode: 200, data: anyData())
        })
    }
    
    func test_cancelLoad_cancelsRequestingImageUrl() {
        let (sut, client) = makeSUT()
        let imageURL = anyURL()
     
        let task = sut.load(imageURL, completion: { _ in })
        task.cancel()
        
        XCTAssertEqual(client.cancelledURL, [imageURL])
    }
    
    func test_load_deliversImageDataWith200Response() {
        let (sut, client) = makeSUT()
        
        let exp = expectation(description: "Waits for load() completion")
        let expectedData = anyData()
        
        let _ = sut.load(anyURL(), completion: { result in
            switch result {
            case let .success(receivedData):
                XCTAssertEqual(receivedData, expectedData)
            default:
                XCTFail("Expected success with image data, found \(result) instead")
            }
            exp.fulfill()
        })
        
        client.complete(withStatusCode: 200, data: anyData())
        wait(for: [exp], timeout: 1.0)
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
    
    private func anyData() -> Data {
        return "any data".data(using: .utf8)!
    }
    
    private class HTTPClientSpy: HTTPFeedImageLoaderClient {
        var requestedURLs: [URL] {
            messages.map{ $0.url }
        }
        
        private(set) var cancelledURL = [URL]()
        
        private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        
        func get(_ url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPFeedImageLoaderClientTask {
            messages.append((url, completion))
            return HTTPClientTaskSpy { [weak self] in
                self?.cancelledURL.append(url)
            }
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
    
    private class HTTPClientTaskSpy: HTTPFeedImageLoaderClientTask {
        let closure: () -> Void
        
        init(closure: @escaping () -> Void) {
            self.closure = closure
        }
        
        func cancel() {
            closure()
        }
    }
    
}

extension HTTPURLResponse {
    var isOK: Bool {
        return statusCode == 200
    }
}
