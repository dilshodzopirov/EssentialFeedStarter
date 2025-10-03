//
//  Created by Dilshod Zopirov on 9/24/25.
//

import UIKit
import EssentialFeed

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
        cell?.onRetry = delegate.loadImageData
        cell?.onReuse = { [weak self] in
            self?.releaseCellForReuse()
        }
        delegate.loadImageData()
        return cell!
    }
    
    func preload() {
        delegate.loadImageData()
    }
    
    func cancelLoad() {
        releaseCellForReuse()
        delegate.cancelImageDataLoad()
    }
    
    func display(_ viewModel: FeedImageViewModel<Image>) {
        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        cell?.feedImageView.setImageAnimated(viewModel.image)
        cell?.feedImageContainer.isShimmering = viewModel.isLoading
        cell?.feedImageRetryButton.isHidden = !viewModel.shouldRetry
    }
    
    private func releaseCellForReuse() {
        cell?.onReuse = nil
        cell = nil
    }
}
