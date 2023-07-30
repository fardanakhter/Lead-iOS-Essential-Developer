//
//  CommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Fardan Akhter on 30/07/2023.
//

import XCTest
import UIKit
import EssentialFeed
import EssentialFeediOS
import EssentialApp

final class CommentsUIIntegrationTests: FeedUIIntegrationTest {
    
    func test_commentsViewController_hasNavigationTitle() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, ImageCommentsPresenter.imageCommentsViewTitle, "Comments View title mismatched!")
    }
    
    override func test_loadFeedActions_loadsFeed() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCallCount, 0, "Expected to not load feed when view is not loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1, "Expected to load feed when view is loaded")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected to load feed on user's manual reload")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3, "Expected to load feed on user's multiple manual reloads")
    }
    
    override func test_loadsFeedActions_showsLoadingIndicator() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected to show loading indicator when view is loaded")
        
        loader.completeFeedLoadingSuccessfully(at: 0)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected to hide loading indicator when load feed is completed")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected to show loading indicator when user reloads")
        
        loader.completeFeedLoadingFailing(at: 1)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected to hide loading indicator when load feed initiated by user is completed")
    }
    
    override func test_loadCompletion_rendersSuccessfullyLoadedFeeds() {
        let (sut, loader) = makeSUT()
        let image0 = makeImage(description: "some description", location: "some location")
        let image1 = makeImage(description: "some description", location: nil)
        let image2 = makeImage(description: nil, location: "some location")
        let image3 = makeImage(description: nil, location: nil)
        
        sut.loadViewIfNeeded()
        expect(sut, toRender: [])
        
        loader.completeFeedLoadingSuccessfully(with: [image0, image1], at: 0)
        expect(sut, toRender: [image0, image1])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoadingSuccessfully(with: [image0, image1, image2, image3], at: 1)
        expect(sut, toRender: [image0, image1, image2, image3])
    }
    
    override func test_loadCompletion_rendersSuccessfullyEmptyFeedAfterNonEmptyFeed() {
        let (sut, loader) = makeSUT()
        let image0 = makeImage()
        let image1 = makeImage()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoadingSuccessfully(with: [image0, image1], at: 0)
        expect(sut, toRender: [image0, image1])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoadingSuccessfully(with: [], at: 1)
        expect(sut, toRender: [])
    }
    
    override func test_loadCompletion_doesNotChangeLoadedFeedsWhenCompletesWithError() {
        let (sut, loader) = makeSUT()
        let image0 = makeImage(description: "some description", location: "some location")
        let image1 = makeImage(description: nil, location: nil)
        
        sut.loadViewIfNeeded()
        expect(sut, toRender: [])
        
        loader.completeFeedLoadingSuccessfully(with: [image0, image1], at: 0)
        expect(sut, toRender: [image0, image1])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoadingFailing(with: anyError())
        expect(sut, toRender: [image0, image1])
    }
    
    override func test_loadFeedCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        let exp = expectation(description: "Waiting for load feed completion")
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            loader.completeFeedLoadingSuccessfully(with: [self.makeImage()], at: 0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helper
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (ListViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CommentsUIComposer.commentsUIComposedWith(commentsLoader: loader)
        trackMemoryLeak(loader, file: file, line: line)
        trackMemoryLeak(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any-image-url.com")!) -> FeedImage {
        return FeedImage(id: UUID(), description: description, location: location, url: url)
    }
    
    private func expect(_ sut: ListViewController, toRender images: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        sut.tableView.layoutIfNeeded()
        RunLoop.main.run(until: Date())
        XCTAssertEqual(sut.numberOfFeedImageViews, images.count, file: file, line: line)
        images.enumerated().forEach{ (index, image) in
            assert(that: sut, render: image, at: index, file: file, line: line)
        }
    }
    
    private func assert(that sut: ListViewController, render image: FeedImage, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.simulateImageViewVisible(at: index)
        XCTAssertEqual(view?.imageDescription?.text, image.description, file: file, line: line)
        XCTAssertEqual(view?.isShowingLocation, image.location != nil, file: file, line: line)
        XCTAssertEqual(view?.location?.text, image.location, file: file, line: line)
    }
}
