//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 28/04/2023.
//

import Foundation
import UIKit

protocol FeedRefreshViewControllerDelegate {
    func didStartLoadingFeed()
}

final class FeedRefreshViewController: NSObject, FeedLoadingView {
    @IBOutlet private var view: UIRefreshControl?
    
    var delegate: FeedRefreshViewControllerDelegate?
    
    override init() {}
    
    @IBAction func refresh() {
        delegate?.didStartLoadingFeed()
    }

    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view?.beginRefreshing()
        }
        else {
            view?.endRefreshing()
        }
        
    }
}
