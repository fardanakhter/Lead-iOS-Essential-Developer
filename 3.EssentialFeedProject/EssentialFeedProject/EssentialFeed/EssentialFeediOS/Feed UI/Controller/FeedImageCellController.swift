//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 28/04/2023.
//

import Foundation
import UIKit
import EssentialFeed

public protocol FeedImageCellControllerDelegate {
    func startImageLoading()
    func cancelImageLoading()
}

public final class FeedImageCellController: CellController {
    public typealias Image = UIImage
    
    private var cell: FeedImageCell?
    public var delegate: FeedImageCellControllerDelegate?
    
    public init() {}
    
    public func view(_ tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        delegate?.startImageLoading()
        return cell!
    }
    
    public func preload() {
        delegate?.startImageLoading()
    }
    
    public func cancelTask() {
        removeCellforResuse()
        delegate?.cancelImageLoading()
    }
    
    private func removeCellforResuse() {
        cell = nil
    }
}

extension FeedImageCellController: FeedImageView {
    public func display(_ viewModel: FeedImageViewModel<UIImage>) {
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
