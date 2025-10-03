//
//  Created by Dilshod Zopirov on 10/2/25.
//

import XCTest
import EssentialFeed

struct FeedImageViewModel<Image: Equatable>: Equatable {
    let location: String?
    let description: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        return location != nil
    }
}

protocol FeedImageView {
    associatedtype Image: Equatable
    
    func display(_ viewModel: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private let model: FeedImage
    private let view: View
    private let imageTransformer: (Data) -> Image?

    init(model: FeedImage, view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.model = model
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    func didStartLoadingImageData() {
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
    
    func didFinishLoadingImageData(with data: Data) {
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
    
    func didFinishLoadingImageData(with error: Error) {
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

final class FeedImagePresenterTests: XCTestCase {
    
    func test_init_doesNotMessageView() {
        let (_, view, _) = makeSUT()
        
        XCTAssertEqual(view.viewModel, nil)
    }
    
    func test_didStartLoadingImageData_displaysLocationAndDescriptionAndStartsLoading() {
        let (sut, view, model) = makeSUT()
        sut.didStartLoadingImageData()
        
        assertThat(view, model: model, image: nil, isLoading: true, shoudRetry: false)
    }
    
    func test_didFinishLoadingImageDataWithValidData_displaysLocationAndDescriptionAndImageAndStopsLoading() {
        let anyData = Data("any-data".utf8)
        let (sut, view, model) = makeSUT(imageTransformer: successfullImageTransformer)
        sut.didFinishLoadingImageData(with: anyData)
        
        assertThat(view, model: model, image: MockImage(data: anyData), isLoading: false, shoudRetry: false)
    }
    
    func test_didFinishLoadingImageDataInvalidData_displaysLocationAndDescriptionAndRetryButtonAndStopsLoading() {
        let anyData = Data("any-data".utf8)
        let (sut, view, model) = makeSUT(imageTransformer: failingImageTransformer)
        sut.didFinishLoadingImageData(with: anyData)
        
        assertThat(view, model: model, image: nil, isLoading: false, shoudRetry: true)
    }
    
    func test_didFinishLoadingImageDataWithError_displaysLocationAndDescriptionAndRetryButtonAndStopsLoading() {
        let (sut, view, model) = makeSUT()
        sut.didFinishLoadingImageData(with: anyNSError())
        
        assertThat(view, model: model, image: nil, isLoading: false, shoudRetry: true)
    }
    
    // MARK: Helpers
    
    private func makeSUT(imageTransformer: @escaping (Data) -> MockImage? = { _ in MockImage(data: Data()) }, file: StaticString = #filePath, line: UInt = #line) -> (
        sut: FeedImagePresenter<ViewSpy<MockImage>, MockImage>,
        view: ViewSpy<MockImage>,
        model: FeedImage
    ) {
        let view = ViewSpy<MockImage>()
        let model = uniqueImage()
        let sut = FeedImagePresenter<ViewSpy, MockImage>(model: model, view: view, imageTransformer: imageTransformer)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view, model)
    }
    
    private func assertThat(_ view: ViewSpy<MockImage>, model: FeedImage, image: MockImage?, isLoading: Bool, shoudRetry: Bool, file: StaticString = #filePath, line: UInt = #line) {
        let viewModel = FeedImageViewModel<MockImage>(
            location: model.location,
            description: model.description,
            image: image,
            isLoading: isLoading,
            shouldRetry: shoudRetry
        )
        XCTAssertEqual(view.viewModel, viewModel, file: file, line: line)
    }
    
    private func successfullImageTransformer(data: Data) -> MockImage? {
        return MockImage(data: data)
    }
    
    private func failingImageTransformer(data: Data) -> MockImage? {
        return nil
    }
    
    private class ViewSpy<Image: Equatable>: FeedImageView {
        typealias Image = Image
        var viewModel: FeedImageViewModel<Image>?
        
        func display(_ viewModel: FeedImageViewModel<Image>) {
            self.viewModel = viewModel
        }
    }
    
    private struct MockImage: Equatable {
        private let data: Data
        
        init(data: Data) {
            self.data = data
        }
    }
}
