import Foundation

public protocol FeedImageDataCache {
    typealias Result = Swift.Result<Data, Error>
    func save(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
}
