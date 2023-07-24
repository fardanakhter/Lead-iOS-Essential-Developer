//
//  FeedSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Fardan Akhter on 03/06/2023.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

final class FeedSnapshotTests: XCTestCase {
    
    func test_feedWithContent() {
        let sut = makeSUT()
        
        sut.display(feedWithContent())
        
        assert(sut.snapShot(), named: "Feed_With_Content")
    }
    
    func test_feedWithFailedImageLoading() {
        let sut = makeSUT()
        
        sut.display(feedWithNoImages())
        
        assert(sut.snapShot(), named: "Feed_With_No_Images")
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedView = storyboard.instantiateViewController(withIdentifier: "ListViewController") as! ListViewController
        return feedView
    }
    
    private func feedWithContent() -> [ImageStub] {
        [
            ImageStub(
                description: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritagg protected landmark.",
                location: "some location",
                image: UIImage.make(withColor: .red)),
            
            ImageStub(
                description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
                location: "Garth Pier",
                image: UIImage.make(withColor: .green))
        ]
    }
    
    private func feedWithNoImages() -> [ImageStub] {
        [
            ImageStub(
                description: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritagg protected landmark.",
                location: "some location",
                image: nil,
                showRetry: true),
            
            ImageStub(
                description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
                location: "Garth Pier",
                image: nil,
                showRetry: true)
        ]
    }
}

private class ImageStub: FeedImageCellControllerDelegate {
    private let viewModel: FeedImageViewModel<UIImage>
    weak var controller: FeedImageCellController?
    
    init(description: String?, location: String?, image: UIImage?, showRetry: Bool = false) {
        self.viewModel = FeedImageViewModel(description: description, location: location,
                                            image: image, shouldRetry: showRetry)
    }
    
    func startImageLoading() {
        controller?.display(viewModel)
    }
    
    func cancelImageLoading() {}
}

private extension ListViewController {
    func display(_ stubs: [ImageStub]) {
        display(stubs.map {
            let cellController = FeedImageCellController()
            cellController.delegate = $0
            $0.controller = cellController
            return cellController
        })
    }
}
