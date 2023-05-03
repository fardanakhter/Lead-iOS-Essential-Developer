//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 28/04/2023.
//

import Foundation
import UIKit

final class FeedRefreshViewController: NSObject, FeedLoadingView {
    private(set) lazy var view = make(UIRefreshControl())
    
    private let presenter: FeedViewPresenter
    
    init(presenter: FeedViewPresenter) {
        self.presenter = presenter
    }
    
    @objc func refresh() {
        presenter.refreshFeed()
    }
    
    func display(isLoading: Bool) {
        if isLoading {
            view.beginRefreshing()
        }
        else {
            view.endRefreshing()
        }
    }
    
    func make(_ view: UIRefreshControl) -> UIRefreshControl {
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
