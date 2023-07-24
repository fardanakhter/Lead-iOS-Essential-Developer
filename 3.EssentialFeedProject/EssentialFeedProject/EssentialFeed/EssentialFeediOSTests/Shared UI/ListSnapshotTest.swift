//
//  ListSnapshotTest.swift
//  EssentialFeediOSTests
//
//  Created by Fardan Akhter on 20/07/2023.
//

import XCTest
import EssentialFeediOS

final class ListSnapshotTest: XCTestCase {

    func test_emptyList() {
        let sut = makeSUT()
        
        sut.display(emptyList())
        
        assert(sut.snapShot(), named: "Empty_List")
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedView = storyboard.instantiateViewController(withIdentifier: "ListViewController") as! ListViewController
        return feedView
    }
    
    private func emptyList() -> [CellController] {
        return []
    }
    
}
