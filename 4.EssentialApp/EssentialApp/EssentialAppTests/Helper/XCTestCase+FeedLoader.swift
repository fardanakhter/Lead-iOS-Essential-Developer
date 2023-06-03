//
//  XCTestCase+Helper.swift
//  EssentialAppTests
//
//  Created by Fardan Akhter on 27/05/2023.
//

import XCTest
import EssentialFeed

protocol FeedLoaderTestCase: XCTestCase {}

extension FeedLoaderTestCase {
    func expect(_ sut: FeedLoader, toCompleteWith expectedResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Waiting for load to complete!")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(feed), .success(expectedFeed)):
                XCTAssertEqual(feed, expectedFeed, "Expected received feed to match remote feed", file: file, line: line)
                
            case (.failure, .failure):
                XCTAssertTrue(true)
                
            default:
                XCTFail("Expected load to complete with \(expectedResult), found \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}

