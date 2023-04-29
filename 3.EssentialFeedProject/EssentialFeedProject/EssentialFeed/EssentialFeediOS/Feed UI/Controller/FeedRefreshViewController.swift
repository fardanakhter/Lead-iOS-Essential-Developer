//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 28/04/2023.
//

import Foundation
import UIKit
import EssentialFeed

final class FeedRefreshViewController: NSObject {
    private(set) var feedLoader: FeedLoader?
    private(set) lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()
    
    var onRefresh: (([FeedImage]) -> Void)?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    @objc func refresh() {
        view.beginRefreshing()
        feedLoader?.load { [weak self] result in
            if case let .success(images) = result {
                self?.onRefresh?(images)
            }
            self?.view.endRefreshing()
        }
    }
}
