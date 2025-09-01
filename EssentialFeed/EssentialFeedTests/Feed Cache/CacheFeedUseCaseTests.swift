//
//  CacheFeedUseCaseTests.swift
//  EssentialFeed
//
//  Created by Dilshod Zopirov on 9/1/25.
//

import XCTest
import EssentialFeed

class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    var deleteCallCount = 0
    var insertions: [(items: [FeedItem], timestamp: Date)] = []
    private var deletionCompletions: [DeletionCompletion] = []
    
    func deleteCache(completion: @escaping DeletionCompletion) {
        deleteCallCount += 1
        deletionCompletions.append(completion)
    }
    
    func insert(items: [FeedItem], timestamp: Date) {
        insertions.append((items, timestamp))
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
}

class LocalFeedLoader {
    let store: FeedStore
    let currentDate: () -> Date
    
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(items: [FeedItem]) {
        self.store.deleteCache { [unowned self] error in
            if error == nil {
                self.store.insert(items: items, timestamp: currentDate())
            }
        }
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_doesNotRequestDeleteOnCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.deleteCallCount, 0)
    }
    
    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSUT()
        
        sut.save(items: [uniqueItem(), uniqueItem()])
        
        XCTAssertEqual(store.deleteCallCount, 1)
    }
    
    func test_save_doesNotRequestInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        
        sut.save(items: [uniqueItem(), uniqueItem()])
        
        let deletionError = anyNSError()
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.insertions.count, 0)
    }
    
    func test_save_requestNewCacheInsertionWithTimestampOnSuccessfullDeletion() {
        let time = Date()
        let (sut, store) = makeSUT(currentDate: { time })
        
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items: items)
        
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.insertions.count, 1)
        XCTAssertEqual(store.insertions.first?.items[0], items[0])
        XCTAssertEqual(store.insertions.first?.items[1], items[1])
        XCTAssertEqual(store.insertions.first?.timestamp, time)
    }
    
    // MARK: Helpers
    
    private func makeSUT(currentDate: @escaping() -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
}
