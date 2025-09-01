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
    var insertCallCount = 0
    private var deletionCompletions: [DeletionCompletion] = []
    
    func deleteCache(completion: @escaping DeletionCompletion) {
        deleteCallCount += 1
        deletionCompletions.append(completion)
    }
    
    func insert(items: [FeedItem]) {
       insertCallCount += 1
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
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(items: [FeedItem]) {
        self.store.deleteCache { [unowned self] error in
            if error == nil {
                self.store.insert(items: items)
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
        
        XCTAssertEqual(store.insertCallCount, 0)
    }
    
    func test_save_requestNewCacheInsertionOnSuccessfullDeletion() {
        let (sut, store) = makeSUT()
        
        sut.save(items: [uniqueItem(), uniqueItem()])
        
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.insertCallCount, 1)
    }
    
    // MARK: Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        
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
