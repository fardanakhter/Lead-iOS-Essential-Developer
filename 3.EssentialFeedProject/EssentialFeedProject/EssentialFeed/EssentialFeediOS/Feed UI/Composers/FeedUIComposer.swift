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
        
        let feedPresenter = FeedViewPresenter()
        let adaptor = FeedLoaderPresentationAdaptor(loader: MainQueueDispatchDecorator(decoratee: feedLoader), presenter: feedPresenter)
        
        let feedViewController = makeFeedView()
        feedViewController.title = FeedViewPresenter.feedViewTitle
        
        let refreshController = feedViewController.refreshController!
        refreshController.loadFeed = adaptor.loadFeed

        feedPresenter.feedView = FeedViewAdapter(controller: feedViewController, imageDataLoader: MainQueueDispatchDecorator(decoratee: imageLoader))
        feedPresenter.loadingView = WeakRefProxyInstance(refreshController)
        
        return feedViewController
    }
    
    private static func makeFeedView() -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedViewController = storyboard.instantiateInitialViewController() as! FeedViewController
        return feedViewController
    }
}
