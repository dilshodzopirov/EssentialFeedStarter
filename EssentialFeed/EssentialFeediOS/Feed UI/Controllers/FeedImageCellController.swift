//
//  Created by Dilshod Zopirov on 9/24/25.
//

import UIKit

final class FeedImageCellController: FeedImageView {
    typealias Image = UIImage
    private lazy var cell = FeedImageCell()
    private let presenter: FeedImagePresenter<FeedImageCellController, UIImage>
    
    init(presenter: FeedImagePresenter<FeedImageCellController, UIImage>) {
        self.presenter = presenter
    }
    
    public func view() -> UITableViewCell {
        presenter.loadImageData()
        return cell
    }
    
    func preload() {
        presenter.loadImageData()
    }
    
    func cancelLoad() {
        presenter.cancelImageDataLoad()
    }
    
    func display(_ viewModel: FeedImagePresenterData<Image>) {
        cell.locationContainer.isHidden = !viewModel.hasLocation
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.text = viewModel.description
        cell.onRetry = presenter.loadImageData
        
        cell.feedImageView.image = viewModel.image
        if viewModel.isLoading {
            cell.feedImageContainer.startShimmering()
        } else {
            cell.feedImageContainer.stopShimmering()
        }
        cell.feedImageRetryButton.isHidden = !viewModel.shouldRetry
    }
}
