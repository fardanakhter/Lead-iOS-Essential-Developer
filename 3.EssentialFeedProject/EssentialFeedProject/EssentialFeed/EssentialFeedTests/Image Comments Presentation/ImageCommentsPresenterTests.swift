//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 17/07/2023.
//

import XCTest
import EssentialFeed

final class ImageCommentsPresenterTests: XCTestCase {
    
    func test_map_createsViewModel() {
        let feed = [uniqueImage()]
        
        let viewModel = ImageCommentsPresenter.map(feed)
        
        XCTAssertEqual(viewModel.feed, feed, "Expected to map feed data into view model")
    }
    
    func test_title_isLocalized() {
        let localizedTitle = localizedString(in: Bundle(for: FeedViewPresenter.self), table: "Feed", withKey: "FEED_VIEW_TITLE")
        
        XCTAssertEqual(FeedViewPresenter.feedViewTitle, localizedTitle, "Expected title string to match \(localizedTitle), found \(FeedViewPresenter.feedViewTitle) instead")
    }
    
}
