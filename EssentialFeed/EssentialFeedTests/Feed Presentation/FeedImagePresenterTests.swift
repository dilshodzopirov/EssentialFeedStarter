//
//  Created by Dilshod Zopirov on 10/2/25.
//

import XCTest
import EssentialFeed

struct FeedImageViewModel<Image> {
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
    associatedtype Image
    
    func display(_ viewModel: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private let model: FeedImage
    private let view: View
    
    init(model: FeedImage, view: View) {
        self.model = model
        self.view = view
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
}

final class FeedImagePresenterTests: XCTestCase {
    
    func test_init_doesNotMessageView() {
        let (_, view, _) = makeSUT()
        
        XCTAssertEqual(view.messages.count, 0)
    }
    
    func test_didStartLoadingImageData_displaysLocationAndDescriptionAndStartsLoading() {
        let (sut, view, model) = makeSUT()
        sut.didStartLoadingImageData()
        
        XCTAssertEqual(view.messages, [
            .display(location: model.location, description: model.description, isLoading: true)
        ])
    }
    
    // MARK: Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImagePresenter<ViewSpy<Any>, Any>, view: ViewSpy<Any>, model: FeedImage) {
        let view = ViewSpy<Any>()
        let model = uniqueImage()
        let sut = FeedImagePresenter<ViewSpy, Any>(model: model, view: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view, model)
    }
    
    private class ViewSpy<Image>: FeedImageView {
        typealias Image = Image
        var messages: Set<Message> = []
        
        enum Message: Hashable {
            case display(location: String?, description: String?, isLoading: Bool)
        }
        
        func display(_ viewModel: FeedImageViewModel<Image>) {
            messages.insert(.display(location: viewModel.location, description: viewModel.description, isLoading: viewModel.isLoading))
        }
    }
}
