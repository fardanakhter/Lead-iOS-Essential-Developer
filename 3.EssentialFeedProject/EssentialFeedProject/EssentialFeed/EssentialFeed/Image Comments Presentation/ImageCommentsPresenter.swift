//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 17/07/2023.
//

import Foundation

public struct ImageCommentsViewModel {
    public let comments: [ImageCommentViewModel]
}

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

public final class ImageCommentsPresenter {
   public static var imageCommentsViewTitle: String {
        NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE",
                          tableName: "ImageComments",
                          bundle: Bundle(for: Self.self),
                          comment: "Title for Feed View")
    }
    
    static public func map(_ comments: [ImageComment]) -> ImageCommentsViewModel {
        let formatter = RelativeDateTimeFormatter()
        
        return ImageCommentsViewModel(comments: comments.map{
            ImageCommentViewModel(message: $0.message, date: formatter.localizedString(for: $0.createdAt, relativeTo: Date()), username: $0.username)
        })
    }
}
