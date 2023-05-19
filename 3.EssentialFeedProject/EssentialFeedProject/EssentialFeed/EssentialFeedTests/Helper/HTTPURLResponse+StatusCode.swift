//
//  HTTPURLResponse+StatusCode.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 20/05/2023.
//

import Foundation

extension HTTPURLResponse {
    var isOK: Bool {
        return statusCode == 200
    }
}
