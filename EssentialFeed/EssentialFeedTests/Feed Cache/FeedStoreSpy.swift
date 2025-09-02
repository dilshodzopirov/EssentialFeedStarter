//
//  FeedStoreSpy.swift
//  EssentialFeed
//
//  Created by Dilshod Zopirov on 9/2/25.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
    var receivedMessages: [ReceivedMessage] = []
    private var deletionCompletions: [DeletionCompletion] = []
    private var insertionCompletions: [InsertionCompletion] = []

    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert(_ feed: [LocalFeedImage], date: Date)
    }
    
    func deleteCache(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(feed, date: timestamp))
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](nil)
    }
    
}
