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
    private(set) var refreshController: FeedRefreshViewController?
    private(set) var cellControllers = [IndexPath : FeedImageCellController]()
    
    private var tableModels = [FeedImage]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
        self.init()
        self.refreshController = FeedRefreshViewController(feedLoader: feedLoader)
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = refreshController?.view
        tableView.prefetchDataSource = self
        loadFeed()
    }
    
    @objc private func loadFeed() {
        refreshController?.onRefresh = { [weak self] images in
            self?.tableModels = images
        }
        refreshController?.refresh()
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModels.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(forRowAt: indexPath).view()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        removeCellController(at: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { cellController(forRowAt: $0).preload() }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(removeCellController(at:))
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        let model = tableModels[indexPath.row]
        let imageCellController = FeedImageCellController(model: model, imageLoader: imageLoader!)
        cellControllers[indexPath] = imageCellController
        return imageCellController
    }
    
    private func removeCellController(at indexPath: IndexPath) {
        cellControllers[indexPath] = nil
    }
}
