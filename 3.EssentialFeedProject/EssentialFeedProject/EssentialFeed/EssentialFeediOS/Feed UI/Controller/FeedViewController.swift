//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 20/04/2023.
//

import Foundation
import UIKit

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    @IBOutlet public private(set) var refreshController: FeedRefreshViewController?
    
    private var loadingControllers = [IndexPath : FeedImageCellController]()
    private var tableModels = [FeedImageCellController]()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshController?.refresh()
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModels.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellController(forRowAt: indexPath).view(tableView)
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
        let cell = tableModels[indexPath.row]
        loadingControllers[indexPath] = cell
        return cell
    }
    
    private func removeCellController(at indexPath: IndexPath) {
        loadingControllers[indexPath]?.cancelTask()
        loadingControllers[indexPath] = nil
    }
    
    public func display(_ cellController: [FeedImageCellController]) {
        loadingControllers = [:]
        tableModels = cellController
        tableView.reloadData()
    }
}
