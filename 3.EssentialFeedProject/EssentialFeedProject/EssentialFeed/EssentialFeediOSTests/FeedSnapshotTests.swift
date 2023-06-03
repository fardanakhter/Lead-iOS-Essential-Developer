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

    func test_emptyFeed() {
        let sut = makeSUT()
        
        sut.display(emptyFeed())
        
        record(sut.snapShot(), named: "Empty_Feed")
    }
    
    func test_feedWithContent() {
        let sut = makeSUT()
        
        sut.display(sampleFeed())
        
        record(sut.snapShot(), named: "Feed_With_Content")
    }

    private func makeSUT() -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedView = storyboard.instantiateViewController(withIdentifier: "FeedViewController") as! FeedViewController
        return feedView
    }
    
    private func emptyFeed() -> [FeedImageCellController] {
        return []
    }
    
    private func sampleFeed() -> [ImageStub] {
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
    
    private func record(_ snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
        guard let data = snapshot.pngData() else {
            return XCTFail("Cannot record snapshot", file: file, line: line)
        }
        
        let snapshotURL = URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appending(path: "snapshot")
            .appending(path: "\(name).png")
            
        do {
            try FileManager.default.createDirectory(at: snapshotURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            
            try data.write(to: snapshotURL)
        }
        catch {
            XCTFail("Failed to record snapshot", file: file, line: line)
        }
        
    }
}

private class ImageStub: FeedImageCellControllerDelegate {
    private let viewModel: FeedImageViewModel<UIImage>
    weak var controller: FeedImageCellController?
    
    init(description: String?, location: String?, image: UIImage?) {
        self.viewModel = FeedImageViewModel(description: description, location: location,
                                            image: image, shouldRetry: false)
    }
    
    func startImageLoading() {
        controller?.display(viewModel)
    }
    
    func cancelImageLoading() {}
}

private extension FeedViewController {
    func display(_ stubs: [ImageStub]) {
        display(stubs.map {
            let cellController = FeedImageCellController()
            cellController.delegate = $0
            $0.controller = cellController
            return cellController
        })
    }
}

private extension UIViewController {
    func snapShot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { context in
            view.layer.render(in: context.cgContext)
        }
    }
}
