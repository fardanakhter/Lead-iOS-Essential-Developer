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
    private(set) var imageLoaderTask = [Int: FeedImageDataLoaderTask?]()
    
    private(set) var feedRefreshController: FeedRefreshViewController?
    
    private(set) var tableModels = [FeedImage]()
    
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
            self?.tableView.reloadData()
        }
        feedRefreshController?.refresh()
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModels.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = tableModels[indexPath.row]
        let cell = FeedImageCell()
        cell.imageDescription = model.description
        cell.location = model.location
        cell.locationContainer.isHidden = model.location == nil
        cell.retryImageLoad.isHidden = true
        cell.feedImageView.image = nil
        
        let imageLoad = { [weak self, weak cell] in
            
            guard let self else {return}
            
            imageLoaderTask[indexPath.row] = self.imageLoader?.load(model.url) { [weak cell] result in
                let data = (try? result.get()) ?? nil
                let image = data.map{UIImage(data: $0)} ?? nil
                cell?.feedImageView.image = image
                cell?.retryImageLoad.isHidden = image != nil
            }
        }
        
        cell.retryImageAction = imageLoad
        imageLoad()
        
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelTask(at: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach{ indexPath in
            let model = tableModels[indexPath.row]
            imageLoaderTask[indexPath.row] = self.imageLoader?.load(model.url) { _ in }
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelTask(at:))
    }
    
    private func cancelTask(at indexPath: IndexPath) {
        imageLoaderTask[indexPath.row]??.cancel()
        imageLoaderTask[indexPath.row] = nil
    }
}
