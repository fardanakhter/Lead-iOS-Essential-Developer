//
//  FeedViewPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 12/05/2023.
//

import XCTest
import EssentialFeed

final class FeedViewPresenterTests: XCTestCase {

    func test_map_createsViewModel() {
        let feed = [uniqueImage()]
        
        let viewModel = FeedViewPresenter.map(feed)
        
        XCTAssertEqual(viewModel.feed, feed, "Expected to map feed data into view model")
    }
    
    func test_title_isLocalized() {
        let localizedTitle = localizedString(withKey: "FEED_VIEW_TITLE")
        
        XCTAssertEqual(FeedViewPresenter.feedViewTitle, localizedTitle, "Expected title string to match \(localizedTitle), found \(FeedViewPresenter.feedViewTitle) instead")
    }
}
