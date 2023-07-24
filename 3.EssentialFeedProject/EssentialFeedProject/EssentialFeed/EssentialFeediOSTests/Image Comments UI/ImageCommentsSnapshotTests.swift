//
//  ImageCommentsSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Fardan Akhter on 24/07/2023.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

final class ImageCommentsSnapshotTests: XCTestCase {

    func test_feedWithContent() {
        let sut = makeSUT()
        
        sut.display(feedWithContent())
        
        record(sut.snapShot(), named: "Image_Comments_With_Content")
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedView = storyboard.instantiateViewController(withIdentifier: "ListViewController") as! ListViewController
        return feedView
    }
    
    private func feedWithContent() -> [CellController] {
        [
            ImageCommentViewController (
                model:
                    ImageCommentViewModel(
                        message: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritagg protected landmark.",
                        date: "1000 years ago",
                        username: "a long long long username"
                    )
            ),
            
            ImageCommentViewController (
                model:
                    ImageCommentViewModel(
                        message: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
                        date: "10 months ago",
                        username: "a short username"
                    )
            ),
            
            ImageCommentViewController (
                model:
                    ImageCommentViewModel(
                        message: "nice.",
                        date: "1 day ago",
                        username: "a."
                    )
            )
        ]
    }
    
}
