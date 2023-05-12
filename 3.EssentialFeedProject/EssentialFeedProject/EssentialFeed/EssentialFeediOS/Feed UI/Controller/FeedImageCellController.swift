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
    private var cell: FeedImageCell?
    
    init(presenter: FeedImageViewPresenterInput) {
        self.presenter = presenter
    }
    
    func view(_ tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        presenter.loadImageData()
        return cell!
    }
    
    func preload() {
        presenter.loadImageData()
    }
    
    func cancelTask() {
        removeCellforResuse()
        presenter.cancelImageData()
    }
    
    private func removeCellforResuse() {
        cell = nil
    }
}

extension FeedImageCellController: FeedImageView {
    func display(_ viewModel: FeedImageViewModel<UIImage>) {
        guard let view = cell else { return }
        load(view, with: viewModel)
    }
    
    private func load(_ view: FeedImageCell, with viewModel: FeedImageViewModel<Image>) {
        view.imageDescription?.text = viewModel.description
        view.location?.text = viewModel.location
        view.feedImageView?.setImageAnimation(viewModel.image)
        view.retryImageButton.isHidden = !viewModel.shouldRetry
        view.retryImageAction = presenter.loadImageData
        view.locationContainer?.isHidden = !viewModel.hasLocation
    }
}
