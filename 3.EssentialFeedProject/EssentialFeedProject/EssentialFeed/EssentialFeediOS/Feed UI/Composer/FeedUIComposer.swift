//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 29/04/2023.
//

import Foundation
import UIKit
import EssentialFeed

public class FeedUIComposer {
    private init() {}
    
    public static func feedUIComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedPresenter = FeedViewPresenter(feedLoader: MainQueueDispatchDecorator(decoratee: feedLoader))
        let feedViewController = makeFeedView()
        feedViewController.title = FeedViewPresenter.feedViewTitle
        
        let refreshController = feedViewController.refreshController!
        refreshController.loadFeed = feedPresenter.loadFeed

        feedPresenter.feedView = FeedViewAdapter(controller: feedViewController, imageDataLoader: MainQueueDispatchDecorator(decoratee: imageLoader))
        feedPresenter.feedLoadingView = WeakRefProxyInstance(refreshController)
        
        return feedViewController
    }
    
    private static func makeFeedView() -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedViewController = storyboard.instantiateInitialViewController() as! FeedViewController
        return feedViewController
    }
}

final class MainQueueDispatchDecorator<T> {
    private let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(_ completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { completion() }
            return
        }
        completion()
    }
}

extension MainQueueDispatchDecorator: FeedLoader where T == FeedLoader {
    func load(completion: @escaping (Result<[FeedImage], Error>) -> Void) {
        decoratee.load {[weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: FeedImageDataLoader where T == FeedImageDataLoader {
    func load(_ url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> FeedImageDataLoaderTask {
        decoratee.load(url) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

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
    func display(_ viewModel: FeedImageViewModel<UIImage>) {
        instance?.display(viewModel)
    }
}

final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let imageDataLoader: FeedImageDataLoader
    
    init(controller: FeedViewController, imageDataLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageDataLoader = imageDataLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.tableModels = viewModel.feed.map {
            let presenter = FeedImageViewPresenter<FeedImageCellController, UIImage>(model: $0, imageLoader: imageDataLoader, imageTransformer: { UIImage(data: $0) })
            let controller = FeedImageCellController(presenter: presenter)
            presenter.view = controller
            return controller
        }
    }
}
