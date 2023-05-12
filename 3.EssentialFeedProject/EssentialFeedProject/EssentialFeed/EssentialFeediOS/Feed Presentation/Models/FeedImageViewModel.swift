//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 04/05/2023.
//

import Foundation

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        location != nil
    }
}
