//
//  SceneDelegateTests.swift
//  EssentialAppTests
//
//  Created by Fardan Akhter on 31/05/2023.
//

import XCTest
import EssentialFeediOS
@testable import EssentialApp

final class SceneDelegateTests: XCTestCase {

    func test_configureWindow_makesWindowKeyAndVisible() {
        let window = WindowSpy()
        let sut = SceneDelegate()
        sut.window = window
        
        sut.configureWindow()
        
        XCTAssertEqual(window.callMakeKeyAndVisibleCount, 1, "Expected to call 'makeKeyAndVisible' once but called \(window.callMakeKeyAndVisibleCount) times")
    }
    
    func test_sceneWillConnectToSession_configuresRootViewController() {
        let sut = SceneDelegate()
        sut.window = UIWindow()
        
        sut.configureWindow()
        let root = sut.window?.rootViewController
        let rootNavigation = root as? UINavigationController
        let topNavigation = rootNavigation?.topViewController
        
        XCTAssertNotNil(rootNavigation, "Expected a navigation controller as root, got \(String(describing: root)) instead")
        XCTAssertTrue(topNavigation is FeedViewController, "Expected a feed controller as top view controller, got \(String(describing: topNavigation))) instead")
    }
    
    private class WindowSpy: UIWindow {
        private(set) var callMakeKeyAndVisibleCount: Int = 0
        
        override func makeKeyAndVisible() {
            callMakeKeyAndVisibleCount += 1
        }
    }
    
}
