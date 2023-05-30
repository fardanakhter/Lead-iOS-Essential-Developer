//
//  EssentialAppUIAcceptanceTests.swift
//  EssentialAppUIAcceptanceTests
//
//  Created by Fardan Akhter on 29/05/2023.
//

import XCTest

final class EssentialAppUIAcceptanceTests: XCTestCase {

    func test_onLaunch_displaysRemoteFeedWhenAppHasConnectivity() {
        let app = XCUIApplication()
        app.launchArguments = ["reset", "-connectivity", "online"]
        
        app.launch()
        
        let feedCells = app.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(feedCells.count, 2)
        
        let feedImage = app.images.matching(identifier: "feed-image-view").firstMatch
        XCTAssertTrue(feedImage.exists)
    }
    
    func test_onLaunch_displaysCachedFeedWhenAppHasNoConnectivity() {
        let onlineApp = XCUIApplication()
        onlineApp.launchArguments = ["reset", "-connectivity", "online"]
        onlineApp.launch()

        let offlineApp = XCUIApplication()
        offlineApp.launchArguments = ["-connectivity", "offline"]
        offlineApp.launch()

        let cachedFeedCells = offlineApp.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(cachedFeedCells.count, 2)
        
        let firstCachedImage = offlineApp.images.matching(identifier: "feed-image-view").firstMatch
        XCTAssertTrue(firstCachedImage.exists)
    }
    
    func test_onLaunch_displaysEmptyFeedWhenAppHasNoConnectivityAndCacheIsEmpty() {
        let offlineApp = XCUIApplication()
        offlineApp.launchArguments = ["reset", "-connectivity", "offline"]
        offlineApp.launch()

        let cachedFeedCells = offlineApp.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(cachedFeedCells.count, 0)
    }
}
