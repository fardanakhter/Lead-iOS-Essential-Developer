//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 28/04/2023.
//

import Foundation
import UIKit
import EssentialFeed

public protocol ListRefreshViewControllerDelegate {
    func didStartLoadingList()
}

public final class ListRefreshViewController: NSObject, ResourceLoadingView {
    @IBOutlet private var view: UIRefreshControl?
    
    public var delegate: ListRefreshViewControllerDelegate?
    
    override init() {}
    
    @IBAction func refresh() {
        delegate?.didStartLoadingList()
    }

    public func display(_ viewModel: ResourceLoadingViewModel) {
        if viewModel.isLoading {
            view?.beginRefreshing()
        }
        else {
            view?.endRefreshing()
        }
        
    }
}
