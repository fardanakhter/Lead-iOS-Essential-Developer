//
//  FeedSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Fardan Akhter on 03/06/2023.
//

import XCTest
import EssentialFeediOS

final class FeedSnapshotTests: XCTestCase {

    func test_emptyFeed() {
        let sut = makeSUT()
        
        sut.display(emptyFeed())
        
        record(sut.takeSnapShot(), named: "Empty_Feed")
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

extension UIViewController {
    func takeSnapShot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { context in
            view.layer.render(in: context.cgContext)
        }
    }
}
