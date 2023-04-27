//
//  Feed Image Loader.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 27/04/2023.
//

import Foundation

public protocol FeedImageDataLoaderTask{
    func cancel()
}

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data,Error>
    
    func load(_ url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask
}
