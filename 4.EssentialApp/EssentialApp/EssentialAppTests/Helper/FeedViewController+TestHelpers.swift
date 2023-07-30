//
//  FeedViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Fardan Akhter on 08/05/2023.
//

import UIKit
import EssentialFeediOS

extension ListViewController {
    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    @discardableResult
    func simulateImageViewVisible(at index: Int) -> FeedImageCell? {
        return feedImageView(at: index)
    }
    
    @discardableResult
    func simulateImageViewNotVisible(at index: Int) -> FeedImageCell? {
        guard let view = feedImageView(at: index) else {
            return nil
        }
        let indexpath = IndexPath(row: index, section: feedImageViewsSection)
        let delegate = tableView.delegate!
        delegate.tableView?(tableView, didEndDisplaying: view, forRowAt: indexpath)
        return view
    }
    
    func simulateImageViewNearVisible(at index: Int) {
        let ds = tableView.prefetchDataSource
        let indexpath = IndexPath(row: index, section: feedImageViewsSection)
        ds?.tableView(tableView, prefetchRowsAt: [indexpath])
    }
    
    func simulateImageViewNotNearVisible(at index: Int) {
        simulateImageViewNearVisible(at: index)
        let ds = tableView.prefetchDataSource
        let indexpath = IndexPath(row: index, section: feedImageViewsSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexpath])
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
    
    var numberOfFeedImageViews: Int {
        return tableView.numberOfRows(inSection: feedImageViewsSection)
    }
    
    private var feedImageViewsSection: Int {
        return 0
    }
    
    private func feedImageView(at index: Int) -> FeedImageCell? {
        guard index < numberOfFeedImageViews else {
            return nil
        }
        let indexpath = IndexPath(row: index, section: feedImageViewsSection)
        let ds = tableView.dataSource!
        return ds.tableView(tableView, cellForRowAt: indexpath) as? FeedImageCell
    }
}

