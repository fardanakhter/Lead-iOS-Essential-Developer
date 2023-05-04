//
//  FeedImageCellPresenter.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 03/05/2023.
//

import Foundation
import EssentialFeed

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        location != nil
    }
}

protocol FeedImageView: AnyObject {
    associatedtype Image
    
    func display(_ viewModel: FeedImageViewModel<Image>)
}

final class FeedImageViewPresenter<View: FeedImageView, Image> where View.Image == Image {
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?
    
    private let imageTransformer: (Data) -> Image?
    
    weak var view: View?
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader, imageTransformer: @escaping (Data) -> Image?){
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }
    
    func loadImage() {
        view?.display(FeedImageViewModel(description: model.description, location: model.location, image: nil, shouldRetry: false))
        task = imageLoader.load(model.url) { [weak self] result in
            self?.handle(result)
        }
    }
    
    private func handle(_ result: FeedImageDataLoader.Result) {
        if let image = (try? result.get()).flatMap(imageTransformer) {
            view?.display(FeedImageViewModel(description: model.description, location: model.location, image: image, shouldRetry: false))
        }
        else {
            view?.display(FeedImageViewModel(description: model.description, location: model.location, image: nil, shouldRetry: true))
        }
    }
    
    func loadImageData() {
        task = imageLoader.load(model.url) { _ in }
    }
    
    func cancelImageData() {
        task?.cancel()
    }
}
