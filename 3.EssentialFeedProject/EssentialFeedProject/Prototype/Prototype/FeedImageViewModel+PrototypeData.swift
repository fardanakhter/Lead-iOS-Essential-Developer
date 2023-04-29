//
//  FeedImageViewModel+PrototypeData.swift
//  Prototype
//
//  Created by Fardan Akhter on 18/04/2023.
//

import Foundation

extension FeedImageViewModel {
    static var prototypeFeed: [FeedImageViewModel] = [
        .init(description: "Description\nDescription\nDescription", location: "Location\nLocation", image: "image01"),
        .init(description: "Description", location: "Location", image: "image02"),
        .init(description: "Description\nDescription\nDescription", location: nil, image: "image03"),
        .init(description: nil, location: "Location\nLocation", image: "image04"),
        .init(description: "Description\nDescription\nDescription", location: "Location", image: "image05")
    ]
}
