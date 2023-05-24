//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Fardan Akhter on 25/05/2023.
//

import Foundation

func anyURL() -> URL {
    URL(string: "https://any-url.com")!
}

func anyError() -> NSError {
    NSError(domain: "any-error", code: 0)
}

func anyData() -> Data {
    "any-data".data(using: .utf8)!
}
