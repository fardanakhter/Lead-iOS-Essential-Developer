//
//  CommentsViewAdapter.swift
//  EssentialApp
//
//  Created by Fardan Akhter on 31/07/2023.
//

import Foundation
import EssentialFeed
import EssentialFeediOS

final class CommentsViewAdapter: ResourceView {
    private weak var controller: ListViewController?
    
    init(controller: ListViewController) {
        self.controller = controller
    }
    
    func display(_ viewModel: ImageCommentsViewModel) {
        controller?.display(viewModel.comments.map(ImageCommentViewController.init(model:)))
    }
}
