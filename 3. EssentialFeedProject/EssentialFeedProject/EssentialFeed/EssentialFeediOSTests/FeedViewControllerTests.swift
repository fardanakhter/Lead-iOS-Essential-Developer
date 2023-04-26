//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Fardan Akhter on 20/04/2023.
//

import XCTest
import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewControllerTest: XCTestCase {
    
    func test_loadFeedActions_loadsFeed() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCallCount, 0, "Expected to not load feed when view is not loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1, "Expected to load feed when view is loaded")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected to load feed on user's manual reload")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3, "Expected to load feed on user's multiple manual reloads")
    }
    
    func test_loadsFeedActions_showsLoadingIndicator() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected to show loading indicator when view is loaded")
        
        loader.completeFeedLoadingSuccessfully()
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected to hide loading indicator when load feed is completed")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected to show loading indicator when user reloads")
        
        loader.completeFeedLoadingSuccessfully()
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected to hide loading indicator when load feed initiated by user is completed")
    }
    
    func test_loadCompletion_rendersSuccessfullyLoadedFeeds() {
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
    
    func test_loadCompletion_doesNotChangeLoadedFeedsWhenCompletesWithError() {
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
    
    func test_feedImageView_loadsImageURLWhenViewIsVisible() {
        let (sut, loader) = makeSUT()
        let imageURL = URL(string: "https:/any-image-url.com")!
        let image = makeImage(url: imageURL)
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoadingSuccessfully(with: [image], at: 0)
        
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected to not load image when view is not visible")
        
        sut.simulateImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [imageURL], "Expected to load image when view is visible")
    }
    
    func test_feedImageView_cancelsLoadingImageURLWhenViewIsNotVisible() {
        let (sut, loader) = makeSUT()
        let imageURL = URL(string: "https:/any-image-url.com")!
        let image = makeImage(url: imageURL)
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoadingSuccessfully(with: [image], at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected to not load image when view is not visible")
        
        sut.simulateImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [imageURL], "Expected to load image when view is visible")
        
        sut.simulateImageViewNotvisible(at: 0)
        XCTAssertEqual(loader.cancelledImageLoadURLs, [imageURL], "Expected to cancel image load when view is invisible")
    }
    
    class LoaderSpy: FeedLoader, FeedImageDataLoader {
        //MARK: - FeedLoader
        private var completions = [(FeedLoader.Result) -> Void]()
        
        var loadCallCount: Int {
            completions.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeFeedLoadingSuccessfully(with images: [FeedImage] = [], at index: Int = 0) {
            completions[index](.success(images))
        }
        
        func completeFeedLoadingFailing(with error: Error, at index: Int = 0) {
            completions[index](.failure(error))
        }
        
        // MARK: - FeedImageDataLoader
        var loadedImageURLs = [URL]()
        
        var cancelledImageLoadURLs = [URL]()
        
        func load(_ url: URL) {
            loadedImageURLs.append(url)
        }
        
        func cancelLoading(_ url: URL) {
            cancelledImageLoadURLs.append(url)
        }
    }
    
    // MARK: - Helper

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (FeedViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(feedLoader: loader, imageLoader: loader)
        trackMemoryLeak(loader, file: file, line: line)
        trackMemoryLeak(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any-image-url.com")!) -> FeedImage {
        return FeedImage(id: UUID(), description: description, location: location, url: url)
    }
    
    private func expect(_ sut: FeedViewController, toRender images: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(sut.numberOfFeedImageViews, images.count, file: file, line: line)
        images.enumerated().forEach{ (index, image) in
            assert(that: sut, render: image, at: index, file: file, line: line)
        }
    }
    
    private func assert(that sut: FeedViewController, render image: FeedImage, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.feedImageView(at: index)
        XCTAssertEqual(view.imageDescription, image.description, file: file, line: line)
        XCTAssertEqual(view.isShowingLocation, image.location != nil, file: file, line: line)
        XCTAssertEqual(view.location, image.location, file: file, line: line)
    }
}

private extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    func simulateImageViewVisible(at index: Int) {
        let _ = feedImageView(at: index)
    }
    
    func simulateImageViewNotvisible(at index: Int) {
        let view = feedImageView(at: index)
        let indexpath = IndexPath(row: index, section: feedImageViewsSection)
        let delegate = tableView.delegate!
        delegate.tableView?(tableView, didEndDisplaying: view, forRowAt: indexpath)
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
    
    var numberOfFeedImageViews: Int {
        return tableView.numberOfRows(inSection: feedImageViewsSection)
    }
    
    private var feedImageViewsSection: Int {
        return 0
    }
    
    func feedImageView(at index: Int) -> FeedImageCell {
        let indexpath = IndexPath(row: index, section: feedImageViewsSection)
        let ds = tableView.dataSource!
        return ds.tableView(tableView, cellForRowAt: indexpath) as! FeedImageCell
    }
}

private extension FeedImageCell {
    var isShowingLocation: Bool {
        !locationContainer.isHidden
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach({ target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({
                (target as NSObject).perform(Selector($0))
            })
        })
    }
    
}
