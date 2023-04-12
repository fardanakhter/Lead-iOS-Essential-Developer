//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 12/04/2023.
//

import Foundation
import CoreData

public final class CoreDataFeedStore {
    private static let modelName = "FeedStore"
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext

    enum StoreError: Error {
        case modelNotFound
        case failedToLoadPersistentContainer
    }
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        guard let managedObjectModel = NSManagedObjectModel.with(name: CoreDataFeedStore.modelName, in: bundle) else {
            throw StoreError.modelNotFound
        }
        do {
            container = try NSPersistentContainer.load(name: CoreDataFeedStore.modelName, model: managedObjectModel, url: storeURL)
            context = container.newBackgroundContext()
        }
        catch {
            throw StoreError.failedToLoadPersistentContainer
        }
    }
    
    deinit {
        cleanUpReferencesToPersistentStores()
    }
    
    func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform {
            action(context)
        }
    }
    
    private func cleanUpReferencesToPersistentStores() {
        context.performAndWait {
            let coordinator = self.container.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }
}

extension CoreDataFeedStore: FeedStore {
    public func loadFeedCache(completion: @escaping LoadCompletion) {
        perform { context in
            do {
                guard let cache = try ManagedFeedCache.find(in: context) else {
                    return completion(.empty)
                }
                completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
            }
            catch(let error) {
                completion(.failure(error))
            }
        }
    }
   
    public func insertFeedCache(with feed: [LocalFeedImage], and timestamp: Date, completion: @escaping InsertCompletion) {
        perform { context in
            do {
                let newInstance = try ManagedFeedCache.newUniqueInstance(in: context)
                newInstance.timestamp = timestamp
                newInstance.feed = ManagedFeedImage.images(from: feed, in: context)
                try context.save()
                completion(nil)
            }
            catch(let error) {
                completion(error)
            }
        }
    }
    
    public func deleteFeedCache(completion: @escaping DeleteCompletion) {
        perform { context in
            do {
                try ManagedFeedCache.find(in: context).map(context.delete).map(context.save)
                completion (nil)
            }
            catch(let error) {
                completion(error)
            }
        }
    }
}
