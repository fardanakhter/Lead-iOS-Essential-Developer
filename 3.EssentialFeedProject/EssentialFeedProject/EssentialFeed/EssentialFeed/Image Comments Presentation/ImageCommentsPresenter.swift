//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 17/07/2023.
//

import Foundation

public final class ImageCommentsPresenter {
   public static var feedViewTitle: String {
        NSLocalizedString("FEED_VIEW_TITLE",
                          tableName: "Feed",
                          bundle: Bundle(for: FeedViewPresenter.self),
                          comment: "Title for Feed View")
    }
    
    static public func map(_ feed: [FeedImage]) -> FeedViewModel {
        return FeedViewModel(feed: feed)
    }
}
