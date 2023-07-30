//
//  ListViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Fardan Akhter on 08/05/2023.
//

import UIKit
import EssentialFeediOS

// MARK: - ListViewController + Shared

extension ListViewController {
    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
}

// MARK: - ListViewController + Comments

extension ListViewController {
    var numberOfCommentViews: Int {
        return tableView.numberOfRows(inSection: commentViewsSection)
    }
    
    private var commentViewsSection: Int {
        return 0
    }
    
    func commentView(at index: Int) -> ImageCommentCell? {
        guard index < numberOfCommentViews else {
            return nil
        }
        let indexpath = IndexPath(row: index, section: commentViewsSection)
        let ds = tableView.dataSource!
        return ds.tableView(tableView, cellForRowAt: indexpath) as? ImageCommentCell
    }
}

// MARK: - ListViewController + Feed

extension ListViewController {
    var numberOfFeedImageViews: Int {
        return tableView.numberOfRows(inSection: feedImageViewsSection)
    }
    
    private var feedImageViewsSection: Int {
        return 0
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
    
    private func feedImageView(at index: Int) -> FeedImageCell? {
        guard index < numberOfFeedImageViews else {
            return nil
        }
        let indexpath = IndexPath(row: index, section: feedImageViewsSection)
        let ds = tableView.dataSource!
        return ds.tableView(tableView, cellForRowAt: indexpath) as? FeedImageCell
    }
}

