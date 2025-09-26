//
//  Created by Dilshod Zopirov on 9/26/25.
//

import UIKit
import EssentialFeed

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedViewModel = FeedViewModel(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(viewModel: feedViewModel)
        let vc = FeedViewController(refreshController: refreshController)
        feedViewModel.onFeedLoad = adaptFeedToCellControllers(forwardingTo: vc, imageLoader: imageLoader)
        return vc
    }
    
    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, imageLoader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
        return { [weak controller] feed in
            controller?.tableModel = feed.map {
                let feedImageViewModel = FeedImageViewModel(
                    model: $0,
                    imageLoader: imageLoader,
                    imageTransformer: UIImage.init
                )
                return FeedImageCellController(viewModel: feedImageViewModel)
            }
        }
    }
}
