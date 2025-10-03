//
//  Created by Dilshod Zopirov on 10/3/25.
//

import Foundation

public protocol FeedImageView {
    associatedtype Image: Equatable
    
    func display(_ viewModel: FeedImageViewModel<Image>)
}

public final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private let model: FeedImage
    private let view: View
    private let imageTransformer: (Data) -> Image?

    public init(model: FeedImage, view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.model = model
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    public func didStartLoadingImageData() {
        view.display(
            FeedImageViewModel(
                location: model.location,
                description: model.description,
                image: nil,
                isLoading: true,
                shouldRetry: false
            )
        )
    }
    
    private struct InvalidImageDataError: Error {}
    
    public func didFinishLoadingImageData(with data: Data) {
        guard let image = imageTransformer(data) else {
            return didFinishLoadingImageData(with: InvalidImageDataError())
        }
        
        view.display(
            FeedImageViewModel(
                location: model.location,
                description: model.description,
                image: image,
                isLoading: false,
                shouldRetry: false
            )
        )
    }
    
    public func didFinishLoadingImageData(with error: Error) {
        view.display(
            FeedImageViewModel(
                location: model.location,
                description: model.description,
                image: nil,
                isLoading: false,
                shouldRetry: true
            )
        )
    }
}

