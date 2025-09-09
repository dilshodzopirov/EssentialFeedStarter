//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by Dilshod Zopirov on 9/9/25.
//

import XCTest
import EssentialFeed

final class EssentialFeedCacheIntegrationTests: XCTestCase {

    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { result in
            switch result {
            case let .success(feed):
                XCTAssertEqual(feed, [], "Expected empty feed")
            case let .failure(error):
                XCTFail("Expected success, got \(error) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }

    // MARK: Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = testSpecificURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return sut
    }
    
    private func testSpecificURL() -> URL {
        return cachesDirectory().appending(path: "\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
