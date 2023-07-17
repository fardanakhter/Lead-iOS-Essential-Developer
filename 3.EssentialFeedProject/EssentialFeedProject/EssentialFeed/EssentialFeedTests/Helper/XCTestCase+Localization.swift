//
//  XCTest+Localization.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 17/07/2023.
//

import XCTest

extension XCTestCase {
    public func localizedString(in bundle: Bundle, table: String, withKey key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        
        if value == key {
            XCTFail("Missing localized string for key: \(key)", file: file, line: line)
        }
        return value
    }
}
