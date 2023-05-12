//
//  FeedViewPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 12/05/2023.
//

import XCTest

final class FeedViewPresenter {
    
}

final class FeedViewPresenterTests: XCTestCase {

    func test_init_doesnotRequestEvent() {
        let view = FeedViewSpy()
        
        let _ = FeedViewPresenter()
        
        XCTAssertEqual(view.messages, [])
    }
    
    private class FeedViewSpy {
        private(set) var messages = [String]()
    }
    
}
