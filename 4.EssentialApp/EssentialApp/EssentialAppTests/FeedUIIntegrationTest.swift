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
import EssentialApp

final class FeedUIIntegrationTest: XCTestCase {
    
    func test_feedViewController_hasNavigationTitle() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        let localizedString = localizedString(withKey: "FEED_VIEW_TITLE")
        XCTAssertEqual(sut.title, localizedString, "Feed View title mismatched!")
    }
    
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
        
        loader.completeFeedLoadingSuccessfully(at: 0)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected to hide loading indicator when load feed is completed")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected to show loading indicator when user reloads")
        
        loader.completeFeedLoadingFailing(at: 1)
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
    
    func test_loadCompletion_rendersSuccessfullyEmptyFeedAfterNonEmptyFeed() {
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
    
    func test_feedImageView_rendersImageSuccessfully() {
        let (sut, loader) = makeSUT()
        let imageURL = URL(string: "https//:any-image-url.com")!
        let image = makeImage(url: imageURL)
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoadingSuccessfully(with: [image], at: 0)
        
        let view = sut.simulateImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [imageURL])
        
        loader.completeImageLoadingSuccessfully(with: UIImage.make(withColor: .red).pngData()!, at: 0)
        XCTAssertNotNil(view?.renderedImage)
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
        XCTAssertEqual(loader.cancelledImageLoadURLs, [], "Expected no canceled image requests when no view is not visible yet")
        
        sut.simulateImageViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageLoadURLs, [imageURL], "Expected to cancel image request when view is not visible anymore")
    }
    
    func test_retryImageOption_isShowingWhenLoadingImageURLFails() {
        let (sut, loader) = makeSUT()
        let imageURL = URL(string: "https:/any-image-url.com")!
        let image = makeImage(url: imageURL)
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoadingSuccessfully(with: [image], at: 0)
        
        let view = sut.simulateImageViewVisible(at: 0)
        XCTAssertEqual(view?.isShowingRetryOptionView, false)
        
        loader.completeImageLoadingFailing(at: 0)
        XCTAssertEqual(view?.isShowingRetryOptionView, true)
        
        loader.completeImageLoadingSuccessfully(with: UIImage.make(withColor: .red).pngData()!, at: 0)
        XCTAssertEqual(view?.isShowingRetryOptionView, false)
    }
    
    func test_retryImageOption_loadsImageURL() {
        let (sut, loader) = makeSUT()
        let imageURL = URL(string: "https:/any-image-url.com")!
        let image = makeImage(url: imageURL)
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoadingSuccessfully(with: [image], at: 0)
        
        let view = sut.simulateImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [imageURL], "Expected to load image url")
        XCTAssertEqual(view?.isShowingRetryOptionView, false, "Expected to not show retry option until load completes")
        
        loader.completeImageLoadingFailing(at: 0)
        XCTAssertEqual(view?.isShowingRetryOptionView, true, "Expected to show retry option when load completes with failure")
        
        view?.simulateRetryImageLoad()
        XCTAssertEqual(loader.loadedImageURLs, [imageURL, imageURL], "Expected to reload image url")
    }
    
    func test_feedImageView_preloadWhenIsNearVisible() {
        let (sut, loader) = makeSUT()
        let image1URL = URL(string: "http/:any-image-url.com")!
        let image1 = makeImage(url: image1URL)
        let image2URL = URL(string: "http/:another-any-image-url.com")!
        let image2 = makeImage(url: image2URL)
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoadingSuccessfully(with: [image1, image2], at: 0)
        
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image requests when view is not visible")
        
        sut.simulateImageViewNearVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image1URL], "Expected single image request when a view is near visible")
        
        sut.simulateImageViewNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image1URL, image2URL], "Expected double image requests when two views are near visible")
    }
    
    func test_feedImageView_cancelsPreloadWhenIsNotNearVisible() {
        let (sut, loader) = makeSUT()
        let image1URL = URL(string: "http/:any-image-url.com")!
        let image1 = makeImage(url: image1URL)
        let image2URL = URL(string: "http/:another-any-image-url.com")!
        let image2 = makeImage(url: image2URL)
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoadingSuccessfully(with: [image1, image2], at: 0)
        XCTAssertEqual(loader.cancelledImageLoadURLs, [], "Expected no canceled image requests when no view is not near visible yet")
        
        sut.simulateImageViewNotNearVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageLoadURLs, [image1URL], "Expected to cancel image request when a view is not near visible")
        
        sut.simulateImageViewNotNearVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageLoadURLs, [image1URL, image2URL], "Expected to cancel image requests when views is not near visible")
    }
    
    func test_feedView_doesNotRenderFeedImageWhenFeedImageIsNotVisibleAnymore() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoadingSuccessfully(with: [makeImage()], at: 0)
        
        let view = sut.simulateImageViewNotVisible(at: 0)
        loader.completeImageLoadingSuccessfully(with: UIImage.make(withColor: .red).pngData()!, at: 0)
        
        XCTAssertNil(view?.renderedImage, "Expected to remove reference to view when not visible")
    }
    
    func test_loadFeedCompletion_dispatchesFromBackgroundToMainThread() {
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
    
    func test_loadFeedImageCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoadingSuccessfully(with: [self.makeImage()], at: 0)
        sut.simulateImageViewVisible(at: 0)
        let exp = expectation(description: "Waiting for load feed image completion")
        DispatchQueue.global().async {
            loader.completeImageLoadingSuccessfully(with: UIImage.make(withColor: .red).pngData()!)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helper

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (FeedViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedUIComposer.feedUIComposedWith(feedLoader: loader, imageLoader: loader)
        trackMemoryLeak(loader, file: file, line: line)
        trackMemoryLeak(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any-image-url.com")!) -> FeedImage {
        return FeedImage(id: UUID(), description: description, location: location, url: url)
    }
    
    private func expect(_ sut: FeedViewController, toRender images: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        sut.tableView.layoutIfNeeded()
        RunLoop.main.run(until: Date())
        XCTAssertEqual(sut.numberOfFeedImageViews, images.count, file: file, line: line)
        images.enumerated().forEach{ (index, image) in
            assert(that: sut, render: image, at: index, file: file, line: line)
        }
    }
    
    private func assert(that sut: FeedViewController, render image: FeedImage, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.simulateImageViewVisible(at: index)
        XCTAssertEqual(view?.imageDescription?.text, image.description, file: file, line: line)
        XCTAssertEqual(view?.isShowingLocation, image.location != nil, file: file, line: line)
        XCTAssertEqual(view?.location?.text, image.location, file: file, line: line)
    }
}
