//
//  FeedImageCellViewModel.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 01/05/2023.
//

import Foundation
import EssentialFeed

final class FeedImageCellViewModel<Image> {
    typealias Observer<U> = ((U) -> Void)
    
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?
    
    private let imageTransformer: (Data) -> Image?
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader, imageTransformer: @escaping (Data) -> Image?){
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }

    var description: String? {
        model.description
    }
    
    var location: String? {
        model.location
    }
    
    var hasLocation: Bool {
        model.location != nil
    }
    
    var onImageLoad: Observer<Image>?
    var onShouldRetryLoadingStateChange: Observer<Bool>?
    
    func loadImage() {
        onShouldRetryLoadingStateChange?(false)
        task = imageLoader.load(model.url) { [weak self] result in
            self?.handle(result)
        }
    }
    
    private func handle(_ result: FeedImageDataLoader.Result) {
        if let image = (try? result.get()).flatMap(imageTransformer) {
            onImageLoad?(image)
            onShouldRetryLoadingStateChange?(false)
        }
        else {
            onShouldRetryLoadingStateChange?(true)
        }
    }
    
    func loadImageData() {
        task = imageLoader.load(model.url) { _ in }
    }
    
    func cancelImageData() {
        task?.cancel()
    }
}
