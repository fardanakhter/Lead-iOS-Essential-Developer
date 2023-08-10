//
//  LoadMoreFeedCellController.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 10/08/2023.
//

import Foundation
import UIKit
import EssentialFeed

public class LoadMoreFeedCellController: CellController {
    
    public init(){}
    
    public func view(_ tableView: UITableView) -> UITableViewCell {
        let cell = LoadMoreFeedCell()
        cell.isLoading = true
        return cell
    }
    
    public func preload() {}
    
    public func cancelTask() {}
}
