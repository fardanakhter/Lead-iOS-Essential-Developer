//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 17/07/2023.
//

import XCTest
import EssentialFeed

final class ImageCommentsPresenterTests: XCTestCase {
    
    func test_map_createsViewModel() {
        let now = Date()
        let calendar = Calendar(identifier: .gregorian)
        let locale = Locale(identifier: "en_POSIX")
        
        let comments = [ImageComment(id: UUID(),
                                     message: "a message",
                                     createdAt: now.addingMinutes(-5, calendar: calendar),
                                     username: "a username"),
                        ImageComment(id: UUID(),
                                     message: "another message",
                                     createdAt: now.addingMinutes(-1, calendar: calendar),
                                     username: "another user")]
        
        let viewModel = ImageCommentsPresenter.map(comments, calendar: calendar, locale: locale, currentDate: now)
        
        XCTAssertEqual(viewModel.comments,
                       [ ImageCommentViewModel(message: "a message",
                                               date: "5 minutes ago",
                                               username: "a username"),
                         ImageCommentViewModel(message: "another message",
                                               date: "1 minute ago",
                                               username: "another user")],
                       "Expected to map image comments data into view model")
    }
    
    func test_title_isLocalized() {
        let localizedTitle = localizedString(in: Bundle(for: ImageCommentsPresenter.self), table: "ImageComments", withKey: "IMAGE_COMMENTS_VIEW_TITLE")
        
        XCTAssertEqual(ImageCommentsPresenter.imageCommentsViewTitle, localizedTitle, "Expected title string to match \(localizedTitle), found \(ImageCommentsPresenter.imageCommentsViewTitle) instead")
    }
    
}
