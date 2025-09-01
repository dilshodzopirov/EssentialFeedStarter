//
//  CacheFeedUseCaseTests.swift
//  EssentialFeed
//
//  Created by Dilshod Zopirov on 9/1/25.
//

import XCTest
import EssentialFeed

class FeedStore {
    var deleteCallCount = 0
    
    func deleteCache() {
        deleteCallCount += 1
    }
}

class LocalFeedLoader {
    let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(items: [FeedItem]) {
        store.deleteCache()
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_doesNotRequestDeleteOnCreation() {
        let store = FeedStore()
        XCTAssertEqual(store.deleteCallCount, 0)
    }
    
    func test_save_requestCacheDeletion() {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        
        sut.save(items: [uniqueItem(), uniqueItem()])
        
        XCTAssertEqual(store.deleteCallCount, 1)
    }
    
    // MARK: Helpers
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
}
