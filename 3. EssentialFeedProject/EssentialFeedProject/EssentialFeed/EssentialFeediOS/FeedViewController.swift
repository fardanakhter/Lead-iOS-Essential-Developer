//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 20/04/2023.
//

import Foundation
import UIKit
import EssentialFeed

public protocol FeedImageDataLoader {
    func load(_ url: URL)
    func cancelLoading(_ url: URL)
}

public final class FeedViewController: UITableViewController {
    private(set) var feedLoader: FeedLoader?
    private(set) var imageLoader: FeedImageDataLoader?
    private(set) var tableModels = [FeedImage]()
    
    public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
        self.init()
        self.feedLoader = feedLoader
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
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
        imageLoader?.load(model.url)
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let model = tableModels[indexPath.row]
        imageLoader?.cancelLoading(model.url)
    }
}
