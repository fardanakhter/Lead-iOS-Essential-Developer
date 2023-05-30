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


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let url = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5d1c78f21e661a0001ce7cfd/1562147059075/feed-case-study-v1-api-feed.json")!
        
        let session = URLSession(configuration: .ephemeral)
        let client = makeHttpClient(with: session)
        let remoteFeedLoader = RemoteFeedLoader(url: url, httpClient: client)
        let remoteImageLoader = RemoteFeedImageDataLoader(client)
        
        let localStoreURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("feedStore.store")
        
        if CommandLine.arguments.contains("reset") {
            try? FileManager().removeItem(at: localStoreURL)
        }
        
        let localStore = try! CoreDataFeedStore(storeURL: localStoreURL, bundle: Bundle(for: CoreDataFeedStore.self))
        let localFeedLoader = LocalFeedLoader(store: localStore, timestamp: Date.init)
        let localImageLoader = LocalFeedImageDataLoader(store: localStore)
        
        let feedFallbackLoader = FeedLoaderWithFallbackComposite(primary: FeedLoaderCacheDecorator(decoratee: remoteFeedLoader, cache: localFeedLoader), fallback: localFeedLoader)
        
        let feedImageFallbackLoader = FeedImageDataLoaderWithFallbackComposite(primary: localImageLoader, fallback: FeedImageDataLoaderCacheDecorator(decoratee: remoteImageLoader, cache: localImageLoader))
        
        let feedViewController = FeedUIComposer.feedUIComposedWith(feedLoader: feedFallbackLoader, imageLoader: feedImageFallbackLoader)
        window?.rootViewController = feedViewController
        
    }
    
    private func makeHttpClient(with session: URLSession) -> HTTPClient {
        if let connectivity = UserDefaults.standard.string(forKey: "connectivity"), connectivity == "offline" {
            return FailingHTTPClient()
        }
        return URLSessionHTTPClient(session: session)
    }

    private struct FailingHTTPClient: HTTPClient {
        private struct Task: HTTPClientTask {
            func cancel() {}
        }
        
        func get(_ url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) -> HTTPClientTask {
            completion(.failure(NSError(domain: "", code: 0)))
            return Task()
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

