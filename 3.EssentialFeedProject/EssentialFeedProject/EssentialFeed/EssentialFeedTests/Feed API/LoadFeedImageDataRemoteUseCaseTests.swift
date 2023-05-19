//
//  LoadFeedImageDataRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 19/05/2023.
//

import XCTest
import EssentialFeed

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
        
        XCTAssertEqual(client.cancelledURLs, [imageURL])
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
}


