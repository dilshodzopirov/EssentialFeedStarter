//
//  Created by Dilshod Zopirov on 9/28/25.
//

import EssentialFeed

protocol FeedLoadingView {
    func displayLoading(isLoading: Bool)
}

protocol FeedView {
    func displayFeed(feed: [FeedImage])
}

final class FeedPresenter {
    private let feedLoader: FeedLoader

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var feedView: FeedView?
    var loadingView: FeedLoadingView?

    func loadFeed() {
        loadingView?.displayLoading(isLoading: true)
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.displayFeed(feed: feed)
            }
            self?.loadingView?.displayLoading(isLoading: false)
        }
    }
}
