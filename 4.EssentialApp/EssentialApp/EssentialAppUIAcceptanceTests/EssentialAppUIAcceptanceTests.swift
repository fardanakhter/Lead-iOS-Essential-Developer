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
        app.launch()
        
        XCTAssertEqual(app.cells.count, 6)
    }
}
