//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 28/04/2023.
//

import Foundation
import UIKit

final class FeedImageCellController: FeedImageView {
    private let presenter: FeedImageViewPresenter<FeedImageCellController, UIImage>
    private var imageCell: FeedImageCell?
    
    init(presenter: FeedImageViewPresenter<FeedImageCellController, UIImage>){
        self.presenter = presenter
    }
    
    func view() -> UITableViewCell {
        let view = FeedImageCell()
        self.imageCell = view
        presenter.loadImage()
        return view
    }
    
    func display(_ viewModel: FeedImageViewModel<UIImage>) {
        guard let view = imageCell else { return }
        load(view, with: viewModel)
    }
    
    private func load(_ view: FeedImageCell, with viewModel: FeedImageViewModel<UIImage>) {
        view.imageDescription = viewModel.description
        view.location = viewModel.location
        view.feedImageView.image = viewModel.image
        view.retryImageLoad.isHidden = !viewModel.shouldRetry
        view.retryImageAction = presenter.loadImage
        view.locationContainer.isHidden = !viewModel.hasLocation
    }
    
    func preload() {
        presenter.loadImageData()
    }
    
    func cancelTask() {
        presenter.cancelImageData()
    }
}
