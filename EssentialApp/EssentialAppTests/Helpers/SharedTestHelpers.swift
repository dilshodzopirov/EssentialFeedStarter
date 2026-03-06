import Foundation
import EssentialFeed

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}

func anyData() -> Data {
    return Data("any data".utf8)
}

func uniqueFeed() -> [FeedImage] {
    return [
        FeedImage(
            id: UUID(),
            description: "a description",
            location: "a location",
            url: URL(string: "http://any-url.com")!
        )
    ]
}
