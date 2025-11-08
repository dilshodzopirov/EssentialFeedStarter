//
//  Created by Dilshod Zopirov on 11/8/25.
//

import XCTest

protocol FeedImageDataStore {
    
}

final class LocalFeedImageDataLoader {
    private let store: FeedImageDataStore
    
    init(store: FeedImageDataStore) {
        self.store = store
    }
    
}

final class LocalFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotMessageStore() {
        let store = FeedImageDataStoreSpy()
        let _ = LocalFeedImageDataLoader(store: store)
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    // MARK: Helpers
    
    private final class FeedImageDataStoreSpy: FeedImageDataStore {
        var messages: [Any] = []
    }
    
}
