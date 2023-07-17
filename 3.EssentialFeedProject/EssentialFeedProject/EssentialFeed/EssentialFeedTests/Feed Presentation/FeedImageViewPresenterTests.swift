//
//  FeedImageViewPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 14/05/2023.
//

import XCTest
import EssentialFeed

final class FeedImageViewPresenterTests: XCTestCase {

    func test_map_createsViewModel() {
        let feed = uniqueImage()
        let image = PresenterImage()
        let retryFlag = true
        
        let viewModel = FeedImageViewPresenter<SpyView, PresenterImage>.map(feed, image, retryFlag)
        
        XCTAssertEqual(viewModel.description, feed.description, "Expected to map feed data into view model")
        XCTAssertEqual(viewModel.location, feed.location, "Expected to map feed data into view model")
        XCTAssertEqual(viewModel.image, image, "Expected to map feed data into view model")
        XCTAssertEqual(viewModel.shouldRetry, retryFlag, "Expected to map feed data into view model")
    }
    
    func test_init_doesNotRequestViewEvent() {
        let (_, view) = makeSUT()
        
        XCTAssertEqual(view.messages, [], "Expected no view event")
    }
    
    func test_displayView_requestsViewEventWithCorrectValues() {
        let (sut, view) = makeSUT()
        let feed = uniqueImage()
        let image = PresenterImage()
        let retryFlag = true
        
        sut.displayView(with: feed, image: image, shouldRetry: retryFlag)
        
        XCTAssertEqual(view.messages, [.displayView(model: feed, image: image, retryFlag: retryFlag)], "Expected to report a display view event with correct values")
    }
 
    // MARK: - Helper
    
    private typealias PresenterImage = AnyPresenterImage
    private typealias SpyView = FeedImageViewSpy<PresenterImage>
    
    private func makeSUT() -> (sut: FeedImageViewPresenter<SpyView, PresenterImage>, view: SpyView) {
        
        let view = SpyView()
        let sut = FeedImageViewPresenter<SpyView, PresenterImage>(view: view)
        trackMemoryLeak(view)
        trackMemoryLeak(sut)
        return (sut, view)
    }
    
    private class AnyPresenterImage: Equatable {
        private let id = UUID()
        
        static func == (lhs: AnyPresenterImage, rhs: AnyPresenterImage) -> Bool {
            return lhs.id == rhs.id
        }
    }
    
    private class FeedImageViewSpy<Image: Equatable>: FeedImageView {
        private(set) var messages = [Message]()
        
        enum Message: Equatable {
            case displayView(model: FeedImage, image: Image?, retryFlag: Bool)
        }
        
        func display(_ viewModel: FeedImageViewModel<Image>) {
            let model = FeedImage(id: UUID(), description: viewModel.description, location: viewModel.location, url: anyURL())
            
            messages.append(.displayView(model: model, image: viewModel.image, retryFlag: viewModel.shouldRetry))
        }
    }
    
}

private extension FeedImage {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return (lhs.description == rhs.description &&
                lhs.location == rhs.location &&
                lhs.url == rhs.url)
    }
}
