//
//  ImageCommentViewModel.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 17/07/2023.
//

import Foundation

public struct ImageCommentViewModel: Equatable {
    public let message: String
    public let date: String
    public let username: String
    
    public init(message: String, date: String, username: String) {
        self.message = message
        self.date = date
        self.username = username
    }
}
