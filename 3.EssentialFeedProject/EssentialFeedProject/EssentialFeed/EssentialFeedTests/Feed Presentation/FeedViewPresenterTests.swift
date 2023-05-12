//
//  FeedViewPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 12/05/2023.
//

import XCTest

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

final class FeedViewPresenter {
    let loadingView: FeedLoadingView
    
    init(loadingView: FeedLoadingView) {
        self.loadingView = loadingView
    }
    
    func didStartLoadingFeed() {
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
}

final class FeedViewPresenterTests: XCTestCase {

    func test_init_doesnotRequestEvent() {
        let (_, view) = makeSUT()
        
        XCTAssertEqual(view.messages, [])
    }
    
    func test_didStartLoadingFeed_requestsFeedLoadingEvent() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingFeed()
        
        XCTAssertEqual(view.messages, [.display(isLoading: true)])
    }
    
    private func makeSUT() -> (sut: FeedViewPresenter, view: FeedViewSpy) {
        let view = FeedViewSpy()
        let sut = FeedViewPresenter(loadingView: view)
        trackMemoryLeak(view)
        trackMemoryLeak(sut)
        return (sut, view)
    }
    
    private class FeedViewSpy: FeedLoadingView {
        private(set) var messages = [Message]()
        
        enum Message: Equatable {
            case display(isLoading: Bool)
        }
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.append(.display(isLoading: viewModel.isLoading))
        }
    }
    
}
