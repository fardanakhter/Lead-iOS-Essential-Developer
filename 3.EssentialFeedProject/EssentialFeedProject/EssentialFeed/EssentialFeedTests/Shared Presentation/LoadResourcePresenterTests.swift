//
//  LoadResourcePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 13/07/2023.
//

import XCTest
import EssentialFeed

final class LoadResourcePresenterTests: XCTestCase {
    
    func test_init_doesnotRequestEvent() {
        let (_, view) = makeSUT()
        
        XCTAssertEqual(view.messages, [], "Expected no event on init")
    }
    
    func test_didStartLoadingFeed_startsDisplayingFeedLoading() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingFeed()
        
        XCTAssertEqual(view.messages, [.display(isLoading: true)], "Expected display loading event")
    }
    
    func test_didCompleteLoadingFeedWithFeed_displaysFeedAndStopsDisplayingFeedLoading() {
        let (sut, view) = makeSUT()
        let feed = [uniqueImage()]
        
        sut.didCompleteLoadingFeed(with: feed)
        
        XCTAssertEqual(view.messages, [.display(feed: feed), .display(isLoading: false)], "Expected display feed and display loading events")
    }
    
    func test_didCompleteLoadingFeedWithError_stopsDisplayingFeedLoading() {
        let (sut, view) = makeSUT()
        
        sut.didCompleteLoadingFeed(with: anyError())
        
        XCTAssertEqual(view.messages, [.display(isLoading: false)], "Expected display loading event")
    }
    
    // MARK: - Helper
    
    private func makeSUT() -> (sut: LoadResourcePresenter, view: FeedViewSpy) {
        let view = FeedViewSpy()
        let sut = LoadResourcePresenter(feedView: view, loadingView: view)
        trackMemoryLeak(view)
        trackMemoryLeak(sut)
        return (sut, view)
    }
    
    private class FeedViewSpy: FeedView, FeedLoadingView{
        private(set) var messages = Set<Message>()
        
        enum Message: Hashable {
            case display(isLoading: Bool)
            case display(feed: [FeedImage])
        }
        
        func display(_ viewModel: FeedViewModel) {
            messages.insert(.display(feed: viewModel.feed))
        }
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
    }
}
