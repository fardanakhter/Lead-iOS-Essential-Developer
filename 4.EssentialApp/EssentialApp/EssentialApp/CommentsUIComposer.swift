//
//  CommentsUIComposer.swift
//  EssentialApp
//
//  Created by Fardan Akhter on 30/07/2023.
//

import Foundation
import UIKit
import EssentialFeed
import EssentialFeediOS

public class CommentsUIComposer {
    private init() {}
    
    public static func commentsUIComposedWith(commentsLoader: FeedLoader) -> ListViewController {
        
        let presentationAdaptor = FeedLoaderPresentationAdaptor(loader: MainQueueDispatchDecorator(decoratee: commentsLoader))
        
        let commentsViewController = makeCommentsView()
        commentsViewController.title = FeedViewPresenter.feedViewTitle
        
        let refreshController = commentsViewController.refreshController!
        refreshController.delegate = presentationAdaptor

        presentationAdaptor.presenter = LoadResourcePresenter(view: FeedViewAdapter(controller: commentsViewController,
                                                                                    imageDataLoader: FakeImageDataLoader()),
                                                              loadingView: WeakRefProxyInstance(refreshController),
                                                              mapper: FeedViewPresenter.map)
        return commentsViewController
    }
    
    private static func makeCommentsView() -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let commentsViewController = storyboard.instantiateInitialViewController() as! ListViewController
        return commentsViewController
    }
    
    private class FakeImageDataLoader: FeedImageDataLoader {
        private class FakeFeedImageDataLoaderTask: FeedImageDataLoaderTask {
            func cancel() {}
        }
        
        func load(_ url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> FeedImageDataLoaderTask {
            FakeFeedImageDataLoaderTask()
        }
    }
}

