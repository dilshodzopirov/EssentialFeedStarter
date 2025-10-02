//
//  Created by Dilshod Zopirov on 10/2/25.
//

import XCTest
import EssentialFeed

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}

struct FeedLoadingViewModel {
    let isLoading: Bool
}

struct FeedViewModel {
    let feed: [FeedImage]
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

final class FeedPresenter {
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView
    
    init(feedView: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    private var feedLoadError: String {
        return NSLocalizedString(
            "FEED_VIEW_CONNECTION_ERROR",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: ""
        )
    }
    
    func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        loadingView.display(FeedLoadingViewModel(isLoading: false))
        errorView.display(.error(message: feedLoadError))
    }
}

final class FeedPresenterTests: XCTestCase {
    
    func test_init_doesNotMessageUponCreation() {
        let (_, view) = makeSUT()
        
        XCTAssertEqual(view.messages.count, 0)
    }
    
    func test_didStartFeedLoading_displaysNoErrorMessageAndStartsLoading() {
        let (sut, view) = makeSUT()
        sut.didStartLoadingFeed()
        
        XCTAssertEqual(view.messages, [
            .display(error: nil),
            .display(isLoading: true)
        ]
        )
    }
    
    func test_didFinishLoadingFeed_displaysFeedAndFinishesLoading() {
        let (sut, view) = makeSUT()
        let feed: [FeedImage] = uniqueImageFeed().models
        sut.didFinishLoadingFeed(with: feed)
        
        XCTAssertEqual(view.messages, [
            .display(feed: feed),
            .display(isLoading: false),
        ]
        )
    }
    
    func test_didFinishLoadingFeedWithError_displaysErrorAndFinishesLoading() {
        let (sut, view) = makeSUT()
        sut.didFinishLoadingFeed(with: anyNSError())
        
        XCTAssertEqual(view.messages, [
            .display(error: localized("FEED_VIEW_CONNECTION_ERROR")),
            .display(isLoading: false),
        ]
        )
    }
    
    // MARK: Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (FeedPresenter, ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(feedView: view, loadingView: view, errorView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private class ViewSpy: FeedLoadingView, FeedView, FeedErrorView {
        var messages: Set<Message> = []
        
        enum Message: Hashable {
            case display(error: String?)
            case display(isLoading: Bool)
            case display(feed: [FeedImage])
        }
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: FeedViewModel) {
            messages.insert(.display(feed: viewModel.feed))
        }
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.insert(.display(error: viewModel.message))
        }
    }
    
}
