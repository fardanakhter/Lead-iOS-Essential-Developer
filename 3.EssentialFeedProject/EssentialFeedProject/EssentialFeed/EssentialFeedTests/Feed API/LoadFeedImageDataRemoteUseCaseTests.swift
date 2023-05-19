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
        
        task.wrapper = client.get(url) {[weak self] result in
            guard let _ = self else { return }
            
            task.complete(with: result
                .mapError {_ in .noConnection }
                .flatMap { (data, response) in
                    if response.isOK && !data.isEmpty {
                        return .success(data)
                    }
                    return .failure(.invalidData)
                }
            )
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
        
        expect(sut, toCompleteWith: .failure(.invalidData), when: {
            let invalidData = Data()
            client.complete(withStatusCode: 200, data: invalidData)
        })
    }
    
    func test_load_deliversErrorOnNoInternetConnection() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.noConnection), when: {
            let noConnectionError = NSError(domain: "No Internet Connection", code: 0)
            client.complete(withError: noConnectionError)
        })
    }
    
    func test_load_doesNotDeliverErrorAfterCanceled() {
        let (sut, client) = makeSUT()
        
        assertThatLoadDoesNotCompletesWhenCanceled(given: sut, when: {
            client.complete(withError: anyError())
        })
    }
    
    func test_load_doesNotDeliverImageDataAfterCanceled() {
        let (sut, client) = makeSUT()
        
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
        
        expect(sut, toCompleteWith: .success(anyData()), when: {
            client.complete(withStatusCode: 200, data: anyData())
        })
    }
    
    func test_load_doesNotInvokeCompletionAfterSutIsDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteFeedImageDataLoader? = RemoteFeedImageDataLoader(client)
        
        var capturedResult = [RemoteFeedImageDataLoader.Result]()
        let _ = sut?.load(anyURL()) { result in
            capturedResult.append(result)
        }
        sut = nil
        client.complete(withStatusCode: 200, data: anyData())
        
        XCTAssertEqual(capturedResult.isEmpty, true)
    }
    
    private func makeSUT() -> (RemoteFeedImageDataLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client)
        trackMemoryLeak(sut)
        trackMemoryLeak(client)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteFeedImageDataLoader, toCompleteWith expectedResult: RemoteFeedImageDataLoader.Result, when action: () -> Void) {
        
        let exp = expectation(description: "Waits for load() to complete")
        let _ = sut.load(anyURL(), completion: { receivedResult in
            switch (receivedResult, expectedResult) {
            
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData)
            
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError, expectedError)

            default:
                XCTFail("Expected result \(expectedResult), found result \(receivedResult) instead")
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
