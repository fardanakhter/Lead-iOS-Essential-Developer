//
//  WeakRefProxyInstance.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 11/05/2023.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class WeakRefProxyInstance<T: AnyObject>{
    private(set) weak var instance: T?
    
    init(_ instance: T?) {
        self.instance = instance
    }
}

extension WeakRefProxyInstance: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        instance?.display(viewModel)
    }
}

extension WeakRefProxyInstance: FeedImageView where T: FeedImageCellController {
    typealias Image = FeedImageCellController.Image
    
    func display(_ viewModel: FeedImageViewModel<Image>) {
        instance?.display(viewModel)
    }
}
