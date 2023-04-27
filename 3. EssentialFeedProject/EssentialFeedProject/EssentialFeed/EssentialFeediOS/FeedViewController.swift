//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 20/04/2023.
//

import Foundation
import UIKit
import EssentialFeed

public protocol FeedImageDataLoaderTask{
    func cancel()
}

public protocol FeedImageDataLoader {
    func load(_ url: URL, completion: @escaping (Swift.Result<Data,Error>) -> Void) -> FeedImageDataLoaderTask
}

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private(set) var feedLoader: FeedLoader?
    private(set) var imageLoader: FeedImageDataLoader?
    private(set) var imageLoaderTasks = [Int: FeedImageDataLoaderTask?]()
    
    private(set) var tableModels = [FeedImage]()
    
    public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
        self.init()
        self.feedLoader = feedLoader
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.prefetchDataSource = self
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadFeed), for: .valueChanged)
        loadFeed()
    }
    
    @objc private func loadFeed() {
        refreshControl?.beginRefreshing()
        feedLoader?.load { [weak self] result in
            if case let .success(images) = result {
                self?.tableModels = images
                self?.tableView.reloadData()
            }
            self?.refreshControl?.endRefreshing()
        }
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
            
            let imageLoadTask = self.imageLoader?.load(model.url) { [weak cell] result in
                switch result {
                case let .success(imageData):
                    cell?.feedImageView.image = UIImage(data: imageData)
                    cell?.retryImageLoad.isHidden = true
                    
                case .failure:
                    cell?.retryImageLoad.isHidden = false
                }
            }
            
            imageLoaderTasks[indexPath.row] = imageLoadTask
        }
        
        cell.retryImageAction = imageLoad
        imageLoad()
        
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        imageLoaderTasks[indexPath.row]??.cancel()
        imageLoaderTasks[indexPath.row] = nil
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach{ indexPath in
            let model = tableModels[indexPath.row]
            let imageLoadTask = self.imageLoader?.load(model.url) { _ in }
        }
    }
}
