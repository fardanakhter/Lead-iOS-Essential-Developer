//
//  FeedUIIntegrationTest+Localization.swift
//  EssentialFeediOSTests
//
//  Created by Fardan Akhter on 08/05/2023.
//

import XCTest
import EssentialFeediOS

extension FeedUIIntegrationTest {
    func localizedString(withKey key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let bundle = Bundle(for: FeedViewController.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: "Feed")
        
        if value == key {
            XCTFail("Missing localized string for key: \(key)", file: file, line: line)
        }
        return value
    }
}
