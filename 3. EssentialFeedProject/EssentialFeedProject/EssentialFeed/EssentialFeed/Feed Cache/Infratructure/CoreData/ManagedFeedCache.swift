//
//  ManagedFeedCache.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 12/04/2023.
//

import Foundation
import CoreData

@objc(ManagedCache)
class ManagedFeedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
}

extension ManagedFeedCache {
    static func find(in context: NSManagedObjectContext) throws -> ManagedFeedCache? {
        let request = NSFetchRequest<ManagedFeedCache>(entityName: entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
    
    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedFeedCache {
        try find(in: context).map(context.delete)
        return ManagedFeedCache(context: context)
    }
    
    var localFeed: [LocalFeedImage] {
        return feed.compactMap { ($0 as? ManagedFeedImage)?.local }
    }
}
