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
        if let connectivity = UserDefaults.standard.string(forKey: "connectivity") {
            return DebugginHTTPClient(connectivityStatus: connectivity)
        }
        return super.makeHttpClient()
    }
    
}

private struct DebugginHTTPClient: HTTPClient {
    private let connectivityStatus: String
    
    init(connectivityStatus: String) {
        self.connectivityStatus = connectivityStatus
    }
    
    private struct Task: HTTPClientTask {
        func cancel() {}
    }
    
    func get(_ url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) -> HTTPClientTask {
        completion(Result(catching:{
            switch connectivityStatus {
            case "online":
                return makeSuccessfulResponse(for: url)
            default:
                throw NSError(domain: "offline", code: 0)
            }
        }))
        return Task()
    }
    
    private func makeSuccessfulResponse(for url: URL) -> (Data, HTTPURLResponse) {
        let urlResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: url), urlResponse)
    }
    
    private func makeData(for url: URL) -> Data {
        switch url.absoluteString {
        case "https://any-url.com":
            return makeImageData()
        default:
            return makeFeedData()
        }
    }
    
    private func makeImageData() -> Data {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.red.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!.pngData()!
    }
    
    private func makeFeedData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": [["id" : UUID().uuidString, "image" : "https://any-url.com"],
                                                                      ["id" : UUID().uuidString, "image" : "https://any-url.com"]]])
    }
}
#endif
