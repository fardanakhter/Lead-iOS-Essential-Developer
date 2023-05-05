//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 28/04/2023.
//

import Foundation
import UIKit

final class FeedImageCellController {
    typealias Image = UIImage
    
    private let presenter: FeedImageViewPresenterInput
    private var imageCell: FeedImageCell?
    
    init(presenter: FeedImageViewPresenterInput) {
        self.presenter = presenter
    }
    
    func view(_ tableView: UITableView) -> UITableViewCell {
        let view = tableView.dequeueReusableCell(withIdentifier: "FeedImageCell") as! FeedImageCell
        self.imageCell = view
        presenter.loadImage()
        return view
    }
    
    func preload() {
        presenter.loadImageData()
    }
    
    func cancelTask() {
        presenter.cancelImageData()
    }
}

extension FeedImageCellController: FeedImageView {
    func display(_ viewModel: FeedImageViewModel<UIImage>) {
        guard let view = imageCell else { return }
        load(view, with: viewModel)
    }
    
    private func load(_ view: FeedImageCell, with viewModel: FeedImageViewModel<Image>) {
        view.imageDescription?.text = viewModel.description
        view.location?.text = viewModel.location
        view.feedImageView?.image = viewModel.image
        view.retryImageLoad.isHidden = !viewModel.shouldRetry
        view.retryImageAction = presenter.loadImage
        view.locationContainer?.isHidden = !viewModel.hasLocation
    }
}
