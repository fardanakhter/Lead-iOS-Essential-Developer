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
        perform { _ in }
    }
   
    public func insertFeedCache(with feed: [LocalFeedImage], and timestamp: Date, completion: @escaping InsertCompletion) {
        perform { _ in }
    }
    
    public func deleteFeedCache(completion: @escaping DeleteCompletion) {
        perform { _ in }
    }
}
