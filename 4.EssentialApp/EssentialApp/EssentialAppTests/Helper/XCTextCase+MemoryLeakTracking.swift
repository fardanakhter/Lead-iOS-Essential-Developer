//
//  XCTextCase+MemoryLeakTracking.swift
//  EssentialAppTests
//
//  Created by Fardan Akhter on 24/05/2023.
//

import Foundation
import XCTest

extension XCTestCase {
    func trackMemoryLeak(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Potential Memory Leak Detected!", file: file, line: line)
        }
    }
}
