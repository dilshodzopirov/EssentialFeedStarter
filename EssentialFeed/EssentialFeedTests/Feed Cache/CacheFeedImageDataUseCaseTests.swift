//
//  Created by Dilshod Zopirov on 11/9/25.
//

import XCTest
import EssentialFeed

final class CacheFeedImageDataUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStore() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    func test_saveImageDataForURL_requestsImageDataInsertionForURL() {
        let (sut, store) = makeSUT()
        let data = anyData()
        let url = anyURL()
        
        sut.save(data, for: url) { _ in }
        
        XCTAssertEqual(store.messages, [.insert(data: data, for: url)])
    }
    
    func test_saveImageDataForURL_failsOnStoreInsertionError() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: failed(), when: {
            let insertionError = anyNSError()
            store.completeInsertion(with: insertionError)
        })
    }
    
    func test_saveImageDataForURL_succedsOnSuccessfullStoreInsertion() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success(()), when: {
            store.completeInsertionSuccessfully()
        })
    }
    
    // MARK: Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func failed() -> LocalFeedImageDataLoader.SaveResult {
        .failure(LocalFeedImageDataLoader.SaveError.failed)
    }
    
    private func expect(
        _ sut: LocalFeedImageDataLoader,
        toCompleteWith expectedResult: LocalFeedImageDataLoader.SaveResult,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for completion")
        sut.save(anyData(), for: anyURL()) { receivedResult in
            switch (expectedResult, receivedResult) {
            case (.success, .success):
                break
            case let (.failure(expectedError as LocalFeedImageDataLoader.SaveError), .failure(receivedError as LocalFeedImageDataLoader.SaveError)):
                XCTAssertEqual(expectedError, receivedError, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead.")
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 0.1)
    }
   
}
