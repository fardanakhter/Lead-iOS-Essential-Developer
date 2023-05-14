//
//  FeedImageViewPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 14/05/2023.
//

import XCTest

protocol FeedImageView {
}

final class FeedImageViewPresenter {
    private let view: FeedImageView
    
    init(view: FeedImageView) {
        self.view = view
    }
}

final class FeedImageViewPresenterTests: XCTestCase {

    func test_init_doesNotRequestViewEvent() {
        let (_, view) = makeSUT()
        
        XCTAssertEqual(view.messages, [])
    }
 
    // MARK: - Helper
    
    private func makeSUT() -> (sut: FeedImageViewPresenter, view: FeedImageViewSpy) {
        let view = FeedImageViewSpy()
        let sut = FeedImageViewPresenter(view: view)
        trackMemoryLeak(view)
        trackMemoryLeak(sut)
        return (sut, view)
    }
    
    class FeedImageViewSpy: FeedImageView {
        var messages = [String]()
    }
    
}
