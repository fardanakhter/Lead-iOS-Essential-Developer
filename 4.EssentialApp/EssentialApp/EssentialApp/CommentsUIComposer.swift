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

final class CommentsLoaderPresentationAdaptor: ListRefreshViewControllerDelegate {
    private let loader: ImageCommentLoader
    var presenter: LoadResourcePresenter<[ImageComment], CommentsViewAdapter>?
    
    init(loader: ImageCommentLoader) {
        self.loader = loader
    }
    
    func didStartLoadingList() {
        presenter?.didStartLoadingResource()
        loader.load { [weak self] result in
            switch result {
            case .success(let feed):
                self?.presenter?.didCompleteLoading(with: feed)
            case .failure(let error):
                self?.presenter?.didCompleteLoadingResource(with: error)
            }
        }
    }
}

final class CommentsViewAdapter: ResourceView {
    private weak var controller: ListViewController?
    
    init(controller: ListViewController) {
        self.controller = controller
    }
    
    func display(_ viewModel: ImageCommentsViewModel) {
        controller?.display(viewModel.comments.map(ImageCommentViewController.init(model:)))
    }
}
