//
//  LoaderStub.swift
//  EssentialAppTests
//
//  Created by Fardan Akhter on 27/05/2023.
//

import EssentialFeed

class LoaderStub: FeedLoader {
    let result: FeedLoader.Result
    
    init(result: FeedLoader.Result) {
        self.result = result
    }
    
    func load(completion: @escaping (Result<[FeedImage], Error>) -> Void) {
        completion(result)
    }
}
