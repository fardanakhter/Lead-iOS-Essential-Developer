//
//  ClientCode.swift
//  IntroToModularDesign
//
//  Created by Fardan Akhter on 18/03/2023.
//

import Foundation

// Feed Module

import UIKit

protocol FeedLoader {
    func loadFeed(completion: @escaping ([String]) -> Void)
}

class FeedViewController: UIViewController {
    
    var loader: FeedLoader?
    
    func updateUI() {
        loader?.loadFeed(completion: { feeds in
            // update UI
        })
    }
}

// Remote Feed Module

struct RemoteFeedLoader: FeedLoader {
    func loadFeed(completion: @escaping ([String]) -> Void) {
        // network request
    }
}

// Local Feed Module

struct LocalFeedLoader: FeedLoader {
    func loadFeed(completion: @escaping ([String]) -> Void) {
        // database request
    }
}

// Main Module (composition layer) OR Remote With Fallback Feed Module

struct RemoteWithLocalFallbackLoader: FeedLoader {
    
    // property injection
    let remoteLoader: RemoteFeedLoader
    let localLoader: LocalFeedLoader
    
    func loadFeed(completion: @escaping ([String]) -> Void) {
        let isNetworkReachable = true
        let load = isNetworkReachable ? remoteLoader.loadFeed : localLoader.loadFeed
        load(completion)
    }
}


// Client Code

class Client {
    func execute() {
        let feedVC = FeedViewController()
        feedVC.loader = RemoteFeedLoader()
        feedVC.loader = LocalFeedLoader()
        feedVC.loader = RemoteWithLocalFallbackLoader(
            remoteLoader: RemoteFeedLoader(),
            localLoader: LocalFeedLoader()
        )
    }
}

