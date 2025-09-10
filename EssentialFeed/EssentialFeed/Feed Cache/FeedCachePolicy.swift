//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Dilshod Zopirov on 9/5/25.
//

import Foundation

final class FeedCachePolicy {
    private static var maxCacheAgeInDays: Int { 7 }
    
    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = Calendar(identifier: .gregorian).date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        
        return date < maxCacheAge
    }
}
