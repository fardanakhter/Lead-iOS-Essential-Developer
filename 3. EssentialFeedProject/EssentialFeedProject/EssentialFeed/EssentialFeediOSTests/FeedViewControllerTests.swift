//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Fardan Akhter on 20/04/2023.
//

import XCTest

final class FeedViewController {
    
    private(set) var loader: FeedViewControllerTest.LoaderSpy
    
    init(loader: FeedViewControllerTest.LoaderSpy) {
        self.loader = loader
    }
    
}

final class FeedViewControllerTest: XCTestCase {
    
    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    class LoaderSpy {
        private(set) var loadCallCount: Int = 0
    }
}
