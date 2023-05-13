//
//  FeedImageViewPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 14/05/2023.
//

import XCTest

final class FeedImageViewPresenter {
    
}

final class FeedImageViewPresenterTests: XCTestCase {

    func test_init_doesNotRequestViewEvent() {
        let view = FeedImageViewSpy()
        
        let _ = FeedImageViewPresenter()
        
        XCTAssertEqual(view.messages, [])
    }
 
    class FeedImageViewSpy {
        var messages = [String]()
    }
    
}
