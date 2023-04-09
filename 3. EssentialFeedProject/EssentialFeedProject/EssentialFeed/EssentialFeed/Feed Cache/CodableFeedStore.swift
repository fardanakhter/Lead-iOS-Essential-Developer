//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 10/04/2023.
//

import Foundation

public final class CodableFeedStore: FeedStore {
    
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            feed.map { $0.local }
        }
    }
    
    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        init(from model: LocalFeedImage) {
            self.id = model.id
            self.description = model.description
            self.location = model.location
            self.url = model.url
        }
        
        var local: LocalFeedImage {
            LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    let storeURL: URL
    
    public init(_ storeURL: URL) {
        self.storeURL = storeURL
    }
    
    public func deleteFeedCache(completion: @escaping DeleteCompletion) {
        guard FileManager.default.fileExists(atPath: storeURL.path) else {
            return completion(nil)
        }
        
        do {
            try FileManager.default.removeItem(at: storeURL)
            completion(nil)
        }
        catch(let error) {
            completion(error)
        }
    }
    
    public func insertFeedCache(with feed: [LocalFeedImage], and timestamp: Date, completion: @escaping InsertCompletion) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp))
            try data.write(to: storeURL)
            completion(nil)
        }
        catch(let error) {
            completion(error)
        }
    }
    
    public func loadFeedCache(completion: @escaping LoadCompletion) {
        guard let cachedData = try? Data(contentsOf: storeURL) else {
            completion(.empty)
            return
        }

        do {
            let decoder = JSONDecoder()
            let cahedFeed = try decoder.decode(Cache.self, from: cachedData)
            completion(.found(feed: cahedFeed.localFeed, timestamp: cahedFeed.timestamp))
        }
        catch(let error) {
            completion(.failure(error))
        }
    }
}
