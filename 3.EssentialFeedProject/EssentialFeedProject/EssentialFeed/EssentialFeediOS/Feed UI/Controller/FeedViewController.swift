//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 20/04/2023.
//

import Foundation
import UIKit
import EssentialFeed

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private(set) var imageLoader: FeedImageDataLoader?
    private(set) var feedRefreshController: FeedRefreshViewController?
    private(set) var imageCellControllers = [IndexPath : FeedImageCellController]()
    
    private var tableModels = [FeedImage]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
        self.init()
        self.feedRefreshController = FeedRefreshViewController(feedLoader: feedLoader)
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = feedRefreshController?.view
        tableView.prefetchDataSource = self
        loadFeed()
    }
    
    @objc private func loadFeed() {
        feedRefreshController?.onRefresh = { [weak self] images in
            self?.tableModels = images
        }
        feedRefreshController?.refresh()
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModels.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = tableModels[indexPath.row]
        let imageCellController = FeedImageCellController(model: model, imageLoader: imageLoader!)
        imageCellControllers[indexPath] = imageCellController
        return imageCellController.view()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelTask(at: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach{ indexPath in
            let model = tableModels[indexPath.row]
            let imageCellController = FeedImageCellController(model: model, imageLoader: imageLoader!)
            imageCellController.preload()
            imageCellControllers[indexPath] = imageCellController
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelTask(at:))
    }
    
    private func cancelTask(at indexPath: IndexPath) {
        imageCellControllers[indexPath] = nil
    }
}
