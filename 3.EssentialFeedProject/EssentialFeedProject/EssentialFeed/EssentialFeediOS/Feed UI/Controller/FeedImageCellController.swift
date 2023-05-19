//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 28/04/2023.
//

import Foundation
import UIKit
import EssentialFeed

protocol FeedImageCellControllerDelegate {
    func startImageLoading()
    func cancelImageLoading()
}

final class FeedImageCellController {
    typealias Image = UIImage
    
    private var cell: FeedImageCell?
    var delegate: FeedImageCellControllerDelegate?
    
    func view(_ tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        delegate?.startImageLoading()
        return cell!
    }
    
    func preload() {
        delegate?.startImageLoading()
    }
    
    func cancelTask() {
        removeCellforResuse()
        delegate?.cancelImageLoading()
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
        view.retryImageAction = delegate?.startImageLoading
        view.locationContainer?.isHidden = !viewModel.hasLocation
    }
}
