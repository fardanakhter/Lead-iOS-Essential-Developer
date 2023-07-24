//
//  ImageCommentViewController.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 24/07/2023.
//

import UIKit
import EssentialFeed

public class ImageCommentViewController: CellController {
    
    private let viewModel: ImageCommentViewModel
    
    public init(model: ImageCommentViewModel) {
        self.viewModel = model
    }
    
    public func view(_ tableView: UITableView) -> UITableViewCell {
        UITableViewCell()
    }
    
    public func preload() {
        
    }
    
    public func cancelTask() {
        
    }
}

