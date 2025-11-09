//
//  Created by Dilshod Zopirov on 11/10/25.
//

import XCTest
import EssentialFeed

final class CoreDataFeedImageDataStore: FeedImageDataStore {
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        
    }
    
    func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void) {
        completion(.success(.none))
    }
}

final class CoreDataFeedImageDataStoreTests: XCTestCase {
    
    func test_retrieveImageData_deliversNotFoundWhenEmpty() {
        let sut = CoreDataFeedImageDataStore()
        
        expect(sut, toCompleteRetrievalWith: notFound(), for: anyURL())
    }
    
    // MARK: Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CoreDataFeedImageDataStore {
        let sut = CoreDataFeedImageDataStore()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func notFound() -> FeedImageDataStore.RetrievalResult {
        return .success(.none)
    }
    
    private func expect(
        _ sut: CoreDataFeedImageDataStore,
        toCompleteRetrievalWith expectedResult: FeedImageDataStore.RetrievalResult,
        for url: URL,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for completion")
        sut.retrieve(dataForURL: url) { receivedResult in
            switch (expectedResult, receivedResult) {
            case let (.success(expectedData), .success(receivedResult)):
                XCTAssertEqual(expectedData, receivedResult, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead.", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.1)
    }
   
}
