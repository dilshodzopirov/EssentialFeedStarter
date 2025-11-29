import Foundation
import EssentialFeed

public final class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    private let primaryLoader: FeedImageDataLoader
    private let fallbackLoader: FeedImageDataLoader
    
    private final class Task: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        init(completion: ((FeedImageDataLoader.Result) -> Void)? = nil) {
            self.completion = completion
        }
        
        func cancel() {
            completion = nil
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
    }
    
    public init(primaryLoader: FeedImageDataLoader, fallbackLoader: FeedImageDataLoader) {
        self.primaryLoader = primaryLoader
        self.fallbackLoader = fallbackLoader
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = Task(completion: completion)
        
        _ = primaryLoader.loadImageData(from: url) { [weak self] result in
            switch result {
            case .success:
                task.complete(with: result)
            case .failure:
                _ = self?.fallbackLoader.loadImageData(from: url) { result in
                    task.complete(with: result)
                }
            }
        }
        
        return task
    }
}
