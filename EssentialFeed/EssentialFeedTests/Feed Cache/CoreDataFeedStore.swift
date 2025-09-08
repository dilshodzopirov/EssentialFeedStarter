//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Dilshod Zopirov on 9/8/25.
//

import Foundation

public class CoreDataFeedStore: FeedStore {
    public init() {}
    
    public func deleteCache(completion: @escaping DeletionCompletion) {
        
    }
    
    public func insert(_ feed: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
}
