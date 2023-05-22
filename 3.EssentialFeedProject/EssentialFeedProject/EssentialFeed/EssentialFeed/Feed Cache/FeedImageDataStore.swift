//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 22/05/2023.
//

import Foundation

public protocol FeedImageDataStore {
    typealias InsertionResult = Result<Void, Error>
    typealias InsertCompletion = (InsertionResult) -> Void
    typealias LoadResult = Result<Data?, Error>
    typealias LoadCompletion = (LoadResult) -> Void

    func insert(cache: Data, with url: URL, completion: @escaping InsertCompletion)
    func loadCache(with url: URL, completion: @escaping LoadCompletion)
}
