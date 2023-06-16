//
//  FeedViewPresenterTest+Localization.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 13/05/2023.
//

import XCTest
import EssentialFeedPresentation

extension FeedViewPresenterTests {
    func localizedString(withKey key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let bundle = Bundle(for: FeedViewPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: "Feed")
        
        if value == key {
            XCTFail("Missing localized string for key: \(key)", file: file, line: line)
        }
        return value
    }
}
