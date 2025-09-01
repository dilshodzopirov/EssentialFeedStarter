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
    typealias InsertionCompletion = (Error?) -> Void
    var receivedMessages: [ReceivedMessage] = []
    private var deletionCompletions: [DeletionCompletion] = []
    private var insertionCompletions: [InsertionCompletion] = []

    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert(items: [FeedItem], date: Date)
    }
    
    func deleteCache(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    
    func insert(items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(items: items, date: timestamp))
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

class LocalFeedLoader {
    let store: FeedStore
    let currentDate: () -> Date
    
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(items: [FeedItem], completion: @escaping(Error?) -> Void) {
        self.store.deleteCache { [unowned self] error in
            if error == nil {
                self.store.insert(items: items, timestamp: currentDate(), completion: completion)
            } else {
                completion(error)
            }
        }
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_doesNotMessageStoreOnCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSUT()
        
        sut.save(items: [uniqueItem(), uniqueItem()]) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        
        sut.save(items: [uniqueItem(), uniqueItem()]) { _ in }
        
        let deletionError = anyNSError()
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestNewCacheInsertionWithTimestampOnSuccessfullDeletion() {
        let time = Date()
        let (sut, store) = makeSUT(currentDate: { time })
        
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items: items) { _ in }
        
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(items: items, date: time)])
    }
    
    func test_save_failsOnDeletionError() {
        let time = Date()
        let items = [uniqueItem(), uniqueItem()]
        let deletionError = anyNSError()
        let (sut, store) = makeSUT(currentDate: { time })
        
        var capturedError: Error?
        let exp = expectation(description: "Wait for completion")
        sut.save(items: items) { error in
            capturedError = error
            exp.fulfill()
        }
        
        store.completeDeletion(with: deletionError)
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(capturedError as? NSError, deletionError)
    }
    
    func test_save_failsOnInsertionError() {
        let time = Date()
        let insertionError = anyNSError()
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT(currentDate: { time })
        
        var capturedError: Error?
        let exp = expectation(description: "Wait for completion")
        sut.save(items: items) { error in
            capturedError = error
            exp.fulfill()
        }
        
        store.completeDeletionSuccessfully()
        store.completeInsertion(with: insertionError)
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(capturedError as? NSError, insertionError)
    }
    
    func test_save_succedsOnSuccessfullInsertion() {
        let time = Date()
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT(currentDate: { time })
        
        var capturedError: Error?
        let exp = expectation(description: "Wait for completion")
        sut.save(items: items) { error in
            capturedError = error
            exp.fulfill()
        }
        
        store.completeDeletionSuccessfully()
        store.completeInsertionSuccessfully()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNil(capturedError)
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
