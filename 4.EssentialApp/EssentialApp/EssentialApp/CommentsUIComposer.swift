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
    
    public static func commentsUIComposedWith(commentsLoader: ImageCommentLoader) -> ListViewController {
        
        let presentationAdaptor = CommentsLoaderPresentationAdaptor(loader: MainQueueDispatchDecorator(decoratee: commentsLoader))
        
        let commentsViewController = makeCommentsView()
        commentsViewController.title = ImageCommentsPresenter.imageCommentsViewTitle
        
        let refreshController = commentsViewController.refreshController!
        refreshController.delegate = presentationAdaptor
        
        presentationAdaptor.presenter = LoadResourcePresenter(view: CommentsViewAdapter(controller: commentsViewController),
                                                              loadingView: WeakRefProxyInstance(refreshController),
                                                              mapper: {ImageCommentsPresenter.map($0)})
        return commentsViewController
    }
    
    private static func makeCommentsView() -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let commentsViewController = storyboard.instantiateInitialViewController() as! ListViewController
        return commentsViewController
    }
}
