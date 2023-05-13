//
//  FeedImageCellPresenter.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 03/05/2023.
//

import Foundation
import EssentialFeed

protocol FeedImageView: AnyObject {
    associatedtype Image
    
    func display(_ viewModel: FeedImageViewModel<Image>)
}

final class FeedImageViewPresenter<View: FeedImageView, Image> where View.Image == Image {
    private let view: View
    
    init(view: View) {
        self.view = view
    }
    
    func displayView(with model: FeedImage, image: Image?, shouldRetry: Bool) {
        view.display(FeedImageViewModel(description: model.description, location: model.location, image: image, shouldRetry: shouldRetry))
    }
}
