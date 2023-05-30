//
//  DebuggingSceneDelegate.swift
//  EssentialApp
//
//  Created by Fardan Akhter on 30/05/2023.
//

import UIKit
import EssentialFeed

#if DEBUG
final class DebuggingSceneDelegate: SceneDelegate {
    
    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if CommandLine.arguments.contains("reset") {
            try? FileManager().removeItem(at: localStoreURL)
        }
        super.scene(scene, willConnectTo: session, options: connectionOptions)
    }
    
    override func makeHttpClient() -> HTTPClient {
        if let connectivity = UserDefaults.standard.string(forKey: "connectivity"), connectivity == "offline" {
            return FailingHTTPClient()
        }
        return super.makeHttpClient()
    }
    
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
#endif
