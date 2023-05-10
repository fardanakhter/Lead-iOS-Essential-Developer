//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 28/04/2023.
//

import Foundation
import UIKit

final class FeedRefreshViewController: NSObject, FeedLoadingView {
    @IBOutlet private var view: UIRefreshControl?
    var loadFeed: (() -> Void)?
    
    override init() {}
    
    @IBAction func refresh() {
        loadFeed?()
    }

    func display(_ viewModel: FeedLoadingViewModel) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {[weak self] in self?.display(viewModel) }
            return
        }
        
        if viewModel.isLoading {
            view?.beginRefreshing()
        }
        else {
            view?.endRefreshing()
        }
        
    }
}
