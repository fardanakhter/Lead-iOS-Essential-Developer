//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 29/04/2023.
//

import Foundation
import UIKit
import EssentialFeed
import EssentialFeediOS

public class FeedUIComposer {
    private init() {}
    
    public static func feedUIComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        
        let presentationAdaptor = FeedLoaderPresentationAdaptor(loader: MainQueueDispatchDecorator(decoratee: feedLoader))
        
        let feedViewController = makeFeedView()
        feedViewController.title = FeedViewPresenter.feedViewTitle
        
        let refreshController = feedViewController.refreshController!
        refreshController.delegate = presentationAdaptor

        presentationAdaptor.presenter = FeedViewPresenter(feedView: FeedViewAdapter(controller: feedViewController,
                                                                                    imageDataLoader: MainQueueDispatchDecorator(decoratee: imageLoader)),
                                                          loadingView: WeakRefProxyInstance(refreshController))
        return feedViewController
    }
    
    private static func makeFeedView() -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedViewController = storyboard.instantiateInitialViewController() as! FeedViewController
        return feedViewController
    }
}
