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
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        configureWindow()
    }
    
    func configureWindow() {
        
        func makeCommentListViewController() -> ListViewController {
            let url = URL(string: "https://api.jsonbin.io/v3/qs/64d140638e4aa6225ecc4715")!
            let loader = RemoteLoader(url: url, httpClient: httpClient, mapper: ImageCommentMapper.map)
            let commentListViewController = CommentsUIComposer.commentsUIComposedWith(commentsLoader: loader)
            return commentListViewController
        }
        
        let url = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5d1c78f21e661a0001ce7cfd/1562147059075/feed-case-study-v1-api-feed.json")!
        
        let remoteFeedLoader = RemoteLoader(url: url, httpClient: httpClient, mapper: FeedItemMapper.map)
        let remoteImageLoader = RemoteFeedImageDataLoader(httpClient)
        
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        
        let feedFallbackLoader = FeedLoaderWithFallbackComposite(primary: FeedLoaderCacheDecorator(decoratee: remoteFeedLoader, cache: localFeedLoader), fallback: localFeedLoader)
        let feedImageFallbackLoader = FeedImageDataLoaderWithFallbackComposite(primary: localImageLoader, fallback: FeedImageDataLoaderCacheDecorator(decoratee: remoteImageLoader, cache: localImageLoader))
        
        let feedListViewController = FeedUIComposer.feedUIComposedWith(feedLoader: feedFallbackLoader, imageLoader: feedImageFallbackLoader)
        let navigationController = UINavigationController(rootViewController: feedListViewController)
        
        feedListViewController.didSelectRowAt = { indexPath in
            navigationController.pushViewController(makeCommentListViewController(), animated: true)
        }
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache()
    }
}


extension RemoteLoader: FeedLoader where Resource == [FeedImage] {}

extension RemoteLoader: ImageCommentLoader where Resource == [ImageComment] {}

