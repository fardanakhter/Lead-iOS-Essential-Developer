//
//  FeedImageLoaderPresentationAdaptor.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 14/05/2023.
//

import UIKit
import EssentialFeed

typealias WeakFeedImageCellController = WeakRefProxyInstance<FeedImageCellController>

final class FeedImageLoaderPresentationAdaptor: FeedImageCellControllerDelegate {
    private let model: FeedImage
    private let loader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?
    
    var presenter: FeedImageViewPresenter<WeakFeedImageCellController, UIImage>?
    
    init(model: FeedImage, loader: FeedImageDataLoader){
        self.model = model
        self.loader = loader
    }

    func startImageLoading() {
        presenter?.displayView(with: model, image: nil, shouldRetry: false)
        task = loader.load(model.url) { [weak self] result in
            self?.handle(result)
        }
    }
    
    func cancelImageLoading() {
        task?.cancel()
    }
    
    private func handle(_ result: FeedImageDataLoader.Result) {
        if let image = (try? result.get()).flatMap(UIImage.init) {
            presenter?.displayView(with: model, image: image, shouldRetry: false)
        }
        else {
            presenter?.displayView(with: model, image: nil, shouldRetry: true)
        }
    }
}
