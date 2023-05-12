//
//  FeedViewPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 12/05/2023.
//

import XCTest
import EssentialFeed

struct FeedViewModel {
    let feed: [FeedImage]
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

final class FeedViewPresenter {
    let feedView: FeedView
    let loadingView: FeedLoadingView
    
    init(feedView: FeedView, loadingView: FeedLoadingView) {
        self.feedView = feedView
        self.loadingView = loadingView
    }
    
    func didStartLoadingFeed() {
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didCompleteLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}

final class FeedViewPresenterTests: XCTestCase {

    func test_init_doesnotRequestEvent() {
        let (_, view) = makeSUT()
        
        XCTAssertEqual(view.messages, [], "Expected no event on init")
    }
    
    func test_didStartLoadingFeed_requestsFeedLoadingEvent() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingFeed()
        
        XCTAssertEqual(view.messages, [.display(isLoading: true)], "Expected display loading event")
    }
    
    func test_didCompleteLoadingFeed_requestsFeedEventAndFeedLoadingEvent() {
        let (sut, view) = makeSUT()
        let feed = [uniqueImage()]
        
        sut.didCompleteLoadingFeed(with: feed)
        
        XCTAssertEqual(view.messages, [.display(feed: feed), .display(isLoading: false)], "Expected display feed and display loading events")
    }
    
    // MARK: - Helper
    
    private func makeSUT() -> (sut: FeedViewPresenter, view: FeedViewSpy) {
        let view = FeedViewSpy()
        let sut = FeedViewPresenter(feedView: view, loadingView: view)
        trackMemoryLeak(view)
        trackMemoryLeak(sut)
        return (sut, view)
    }
    
    private class FeedViewSpy: FeedView, FeedLoadingView{
        private(set) var messages = [Message]()
        
        enum Message: Equatable {
            case display(isLoading: Bool)
            case display(feed: [FeedImage])
        }
        
        func display(_ viewModel: FeedViewModel) {
            messages.append(.display(feed: viewModel.feed))
        }
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.append(.display(isLoading: viewModel.isLoading))
        }
    }
    
}
