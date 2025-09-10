//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by Dilshod Zopirov on 9/9/25.
//

import XCTest
import EssentialFeed

final class EssentialFeedCacheIntegrationTests: XCTestCase {

    override func setUp() {
        super.setUp()
        
        cleanStore()
    }
    
    override func tearDown() {
        super.tearDown()
        
        cleanStore()
    }
    
    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toLoad: [])
    }
    
    func test_load_deliversItemsSavedOnASeparateInstance() {
        let savingSUT = makeSUT()
        let loadingSUT = makeSUT()
        let feed = uniqueImageFeed().models
        
        let savingExp = expectation(description: "Wait for save completion")
        savingSUT.save(feed: feed) { error in
            if error != nil {
                XCTFail("Expected to save feed successfully")
            }
            savingExp.fulfill()
        }
        
        wait(for: [savingExp], timeout: 1.0)
        
        expect(loadingSUT, toLoad: feed)
    }
    
    func test_save_overridesPreviousSavedItemsOnASeparateInstance() {
        let firstSUT = makeSUT()
        let latestSUT = makeSUT()
        
        let firstExp = expectation(description: "Wait for first save completion")
        firstSUT.save(feed: uniqueImageFeed().models) { error in
            if error != nil {
                XCTFail("Expected to save feed successfully")
            }
            firstExp.fulfill()
        }
        
        wait(for: [firstExp], timeout: 1.0)
        
        let latestFeed = uniqueImageFeed().models
        let latestExp = expectation(description: "Wait for latest save completion")
        latestSUT.save(feed: latestFeed) { error in
            if error != nil {
                XCTFail("Expected to save feed successfully")
            }
            latestExp.fulfill()
        }
        
        wait(for: [latestExp], timeout: 1.0)
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
    
    private func expect(_ sut: LocalFeedLoader, toLoad expectedFeed: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case let .success(feed):
                XCTAssertEqual(feed, expectedFeed, "Expected empty feed", file: file, line: line)
            case let .failure(error):
                XCTFail("Expected success, got \(error) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func testSpecificURL() -> URL {
        return cachesDirectory().appending(path: "\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func cleanStore() {
        try? FileManager.default.removeItem(at: testSpecificURL())
    }
}
