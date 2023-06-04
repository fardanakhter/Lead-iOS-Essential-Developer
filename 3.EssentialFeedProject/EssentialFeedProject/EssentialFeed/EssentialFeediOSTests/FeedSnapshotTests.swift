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
        
        assert(sut.snapShot(), named: "Empty_Feed")
    }
    
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
    
    private func makeSUT() -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedView = storyboard.instantiateViewController(withIdentifier: "FeedViewController") as! FeedViewController
        return feedView
    }
    
    private func emptyFeed() -> [FeedImageCellController] {
        return []
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
    
    private func assert(_ snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
        guard let snapshotData = snapshot.pngData() else {
            return XCTFail("Cannot record snapshot", file: file, line: line)
        }
        
        let snapshotURL = URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appending(path: "snapshot")
            .appending(path: "\(name).png")
        
        guard let recordedSnapshotData = try? Data(contentsOf: snapshotURL) else {
            return XCTFail("Record snapshot before asserting", file: file, line: line)
        }
        
        if snapshotData != recordedSnapshotData {
            let temporaryURL = FileManager.default.temporaryDirectory.appending(path: snapshotURL.lastPathComponent)
            
            try! snapshotData.write(to: temporaryURL)
            
            XCTAssertEqual(snapshotData, recordedSnapshotData, "snapshot at \(snapshotURL) does not match stored snapshot at \(temporaryURL)", file: file, line: line)
        }
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
