//
//  FeedImageViewPresenter.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 14/05/2023.
//

import Foundation

public protocol FeedImageView: AnyObject {
    associatedtype Image
    
    func display(_ viewModel: FeedImageViewModel<Image>)
}

public final class FeedImageViewPresenter<View: FeedImageView, Image> where View.Image == Image {
    private let view: View
    
    public init(view: View) {
        self.view = view
    }
    
    public func displayView(with model: FeedImage, image: Image?, shouldRetry: Bool) {
        view.display(Self.map(model, image, shouldRetry))
    }
    
    static public func map(_ model: FeedImage, _ image: Image?, _ shouldRetry: Bool) -> FeedImageViewModel<Image> {
        return FeedImageViewModel(description: model.description, location: model.location, image: image, shouldRetry: shouldRetry)
    }
}
