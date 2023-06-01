//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Fardan Akhter on 22/05/2023.
//

import UIKit
import EssentialFeed
import EssentialFeediOS
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        try! CoreDataFeedStore(storeURL: NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("feedStore.store"),
                               bundle: Bundle(for: CoreDataFeedStore.self))
    }()
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, timestamp: Date.init)
    }()
    
    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        configureWindow()
    }
    
    func configureWindow() {
        let url = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5d1c78f21e661a0001ce7cfd/1562147059075/feed-case-study-v1-api-feed.json")!
        
        let remoteFeedLoader = RemoteFeedLoader(url: url, httpClient: httpClient)
        let remoteImageLoader = RemoteFeedImageDataLoader(httpClient)
        
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        
        let feedFallbackLoader = FeedLoaderWithFallbackComposite(primary: FeedLoaderCacheDecorator(decoratee: remoteFeedLoader, cache: localFeedLoader), fallback: localFeedLoader)
        let feedImageFallbackLoader = FeedImageDataLoaderWithFallbackComposite(primary: localImageLoader, fallback: FeedImageDataLoaderCacheDecorator(decoratee: remoteImageLoader, cache: localImageLoader))
        
        let navigationController = UINavigationController(rootViewController: FeedUIComposer.feedUIComposedWith(feedLoader: feedFallbackLoader, imageLoader: feedImageFallbackLoader))
        
        window?.rootViewController = navigationController
    
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache()
    }

}

