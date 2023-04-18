//
//  FeedViewController.swift
//  Prototype
//
//  Created by Fardan Akhter on 17/04/2023.
//

import Foundation
import UIKit

class FeedViewController: UITableViewController {
    let feed = FeedImageViewModel.prototypeFeed
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedImageCell", for: indexPath) as! FeedImageCell
        let model = feed[indexPath.row]
        cell.configure(with: model)
        return cell
    }
}

extension FeedImageCell {
    func configure(with viewModel: FeedImageViewModel) {
        self.locationContainer.isHidden = viewModel.location == nil
        self.locationLabel.text = viewModel.location
        self.descriptionLabel.text = viewModel.description
        self.feedImageView.image = UIImage(named: viewModel.image)
    }
}
