//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 17/07/2023.
//

import Foundation

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
