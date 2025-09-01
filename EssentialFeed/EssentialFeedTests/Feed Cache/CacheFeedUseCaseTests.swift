//
//  CacheFeedUseCaseTests.swift
//  EssentialFeed
//
//  Created by Dilshod Zopirov on 9/1/25.
//

import XCTest

class FeedStore {
    var deleteCallCount = 0
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_doesNotRequestDeleteOnCreation() {
        let store = FeedStore()
        XCTAssertEqual(store.deleteCallCount, 0)
    }
    
}
