//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 06/04/2023.
//

import Foundation

final class FeedCachePolicy {
    private static let calender = Calendar(identifier: .gregorian)
    
    private static var maxCacheAgeInDays: Int {
        return 7
    }
    
    private init(){}
    
    static func validate(_ date: Date, against currentDate: Date) -> Bool {
        guard let maxCacheAge = calender.date(byAdding: .day, value: maxCacheAgeInDays, to: date)
        else { return false }
        return currentDate < maxCacheAge
    }
}
