//
//  LoadMoreFeedCellController.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 10/08/2023.
//

import Foundation
import UIKit
import EssentialFeed

public class LoadMoreFeedCellController: CellController, ResourceLoadingView {
    private let cell = LoadMoreFeedCell()
    
    public init(){}
    
    public func view(_ tableView: UITableView) -> UITableViewCell {
        return cell
    }
    
    public func preload() {}
    
    public func cancelTask() {}
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        cell.isLoading = viewModel.isLoading
    }
}
