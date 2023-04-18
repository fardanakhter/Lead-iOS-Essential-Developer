//
//  FeedViewController.swift
//  Prototype
//
//  Created by Fardan Akhter on 17/04/2023.
//

import Foundation
import UIKit

class FeedViewController: UITableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath)
    }
    
}
