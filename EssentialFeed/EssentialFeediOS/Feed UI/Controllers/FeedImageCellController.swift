//
//  Created by Dilshod Zopirov on 9/24/25.
//

import UIKit

protocol FeedImageCellControllerDelegate {
    func loadImageData()
    func cancelImageDataLoad()
}

final class FeedImageCellController: FeedImageView {
    typealias Image = UIImage
    private var cell: FeedImageCell?
    private let delegate: FeedImageCellControllerDelegate
    
    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    public func view(in tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        cell = tableView.dequeueCell(for: indexPath)
        delegate.loadImageData()
        return cell!
    }
    
    func preload() {
        delegate.loadImageData()
    }
    
    func cancelLoad() {
        delegate.cancelImageDataLoad()
    }
    
    func display(_ viewModel: FeedImageViewModel<Image>) {
        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        cell?.onRetry = delegate.loadImageData
        
        cell?.feedImageView.image = viewModel.image
        if viewModel.isLoading {
            cell?.feedImageContainer.startShimmering()
        } else {
            cell?.feedImageContainer.stopShimmering()
        }
        cell?.feedImageRetryButton.isHidden = !viewModel.shouldRetry
    }
}
