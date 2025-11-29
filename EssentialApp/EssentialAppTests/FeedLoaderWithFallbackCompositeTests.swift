//
//  Created by Dilshod Zopirov on 11/18/25.
//

import XCTest
import EssentialFeed

class FeedLoaderWithFallbackComposite: FeedLoader {
    private let primary: FeedLoader
    
    init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load(completion: completion)
    }
}

final class FeedLoaderWithFallbackCompositeTests: XCTestCase {

    func test_load_deliversPrimaryFeedOnPrimarySuccess() {
        let primaryFeed = uniqueFeed()
        let localFeed = uniqueFeed()
        let primaryLoader = LoaderStub(result: .success(primaryFeed))
        let fallbackLoader = LoaderStub(result: .success(localFeed))
        let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        
        let exp = expectation(description: "Wait for completion")
        sut.load { result in
            switch result {
            case let .success(receivedFeed):
                XCTAssertEqual(receivedFeed, primaryFeed)
            case .failure:
                XCTFail("Expected successfull load feed result, got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private final class LoaderStub: FeedLoader {
        private let result: FeedLoader.Result
        
        init(result: FeedLoader.Result) {
            self.result = result
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(result)
        }
    }
    
    private func uniqueFeed() -> [FeedImage] {
        return [FeedImage(id: UUID(), description: "a description", location: "a location", url: URL(string: "http://any-url.com")!)]
    }
}
