//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 28/04/2023.
//

import Foundation
import UIKit
import EssentialFeed

public protocol FeedRefreshViewControllerDelegate {
    func didStartLoadingFeed()
}

public final class FeedRefreshViewController: NSObject, FeedLoadingView {
    @IBOutlet private var view: UIRefreshControl?
    
    public var delegate: FeedRefreshViewControllerDelegate?
    
    override init() {}
    
    @IBAction func refresh() {
        delegate?.didStartLoadingFeed()
    }

    public func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view?.beginRefreshing()
        }
        else {
            view?.endRefreshing()
        }
        
    }
}
