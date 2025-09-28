//
//  Created by Dilshod Zopirov on 9/28/25.
//

import Foundation
import EssentialFeed

struct FeedImageViewModel<Image> {
    let hasLocation: Bool
    let location: String?
    let description: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
}

protocol FeedImageView: AnyObject {
    associatedtype Image
    
    func display(_ viewModel: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private var task: FeedImageDataLoaderTask?
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private let imageTransformer: (Data) -> Image?
    weak var view: View?
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader, imageTransformer: @escaping (Data) -> Image?) {
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }
    
    var hasLocation: Bool {
        return model.location != nil
    }
    
    var location: String? {
        return model.location
    }
    
    var description: String? {
        return model.description
    }
    
    func loadImageData() {
        view?.display(
            FeedImageViewModel(
                hasLocation: model.location != nil,
                location: model.location,
                description: model.description,
                image: nil,
                isLoading: true,
                shouldRetry: false
            )
        )
        task = imageLoader.loadImageData(from: model.url) { [weak self] result in
            self?.handle(result)
        }
    }
    
    private func handle(_ result: FeedImageDataLoader.Result) {
        if let image = (try? result.get()).flatMap(imageTransformer) {
            view?.display(
                FeedImageViewModel(
                    hasLocation: model.location != nil,
                    location: model.location,
                    description: model.description,
                    image: image,
                    isLoading: false,
                    shouldRetry: false
                )
            )
        } else {
            view?.display(
                FeedImageViewModel(
                    hasLocation: model.location != nil,
                    location: model.location,
                    description: model.description,
                    image: nil,
                    isLoading: false,
                    shouldRetry: true
                )
            )
        }
    }
    
    func cancelImageDataLoad() {
        task?.cancel()
    }
}
