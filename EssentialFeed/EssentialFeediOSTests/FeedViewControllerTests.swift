//
//  FeedViewControllerTests.swift
//  EssentialFeed
//
//  Created by Dilshod Zopirov on 9/14/25.
//

import XCTest

final class FeedViewController {
    init(loader: FeedViewControllerTests.LoaderSpy) {
        
    }
}

class FeedViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoad() {
        let loader = LoaderSpy()
        _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    // MARK: Helpers
   
    class LoaderSpy {
        var loadCallCount = 0
    }

}
