//
//  Created by Dilshod Zopirov on 10/2/25.
//

import XCTest
import EssentialFeed

final class FeedImagePresenterTests: XCTestCase {
    
    func test_init_doesNotMessageView() {
        let image = uniqueImage()
        let (_, view) = makeSUT(image: image)
        
        XCTAssertNil(view.message)
    }
    
    func test_didStartLoadingImageData_displaysLoadingImage() {
        let image = uniqueImage()
        let (sut, view) = makeSUT(image: image)
        
        sut.didStartLoadingImageData()
        
        XCTAssertEqual(view.message?.location, image.location)
        XCTAssertEqual(view.message?.description, image.description)
        XCTAssertEqual(view.message?.isLoading, true)
        XCTAssertEqual(view.message?.shouldRetry, false)
        XCTAssertNil(view.message?.image)
    }
    
    func test_didFinishLoadingImageData_displaysRetryOnFailedImageTransformation() {
        let image = uniqueImage()
        let (sut, view) = makeSUT(image: image, imageTransformer: fail)
        sut.didFinishLoadingImageData(with: Data())
        
        XCTAssertEqual(view.message?.location, image.location)
        XCTAssertEqual(view.message?.description, image.description)
        XCTAssertEqual(view.message?.isLoading, false)
        XCTAssertEqual(view.message?.shouldRetry, true)
        XCTAssertNil(view.message?.image)
    }
    
    func test_didFinishLoadingImageData_displaysImageOnSuccessfullTransformation() {
        let image = uniqueImage()
        let transformedData = MockImage()
        let (sut, view) = makeSUT(image: image, imageTransformer: { _ in transformedData })
        sut.didFinishLoadingImageData(with: Data())
        
        XCTAssertEqual(view.message?.location, image.location)
        XCTAssertEqual(view.message?.description, image.description)
        XCTAssertEqual(view.message?.isLoading, false)
        XCTAssertEqual(view.message?.shouldRetry, false)
        XCTAssertEqual(view.message?.image, transformedData)
    }
    
    func test_didFinishLoadingImageDataWithError_displaysRetry() {
        let image = uniqueImage()
        let (sut, view) = makeSUT(image: image)
        sut.didFinishLoadingImageData(with: anyNSError())
        
        XCTAssertEqual(view.message?.location, image.location)
        XCTAssertEqual(view.message?.description, image.description)
        XCTAssertEqual(view.message?.isLoading, false)
        XCTAssertEqual(view.message?.shouldRetry, true)
        XCTAssertNil(view.message?.image)
    }
    
    // MARK: Helpers
    
    private func makeSUT(image: FeedImage, imageTransformer: @escaping (Data) -> MockImage? = { _ in nil }, file: StaticString = #filePath, line: UInt = #line) -> (
        sut: FeedImagePresenter<ViewSpy<MockImage>, MockImage>,
        view: ViewSpy<MockImage>
    ) {
        let view = ViewSpy<MockImage>()
        let sut = FeedImagePresenter<ViewSpy, MockImage>(model: image, view: view, imageTransformer: imageTransformer)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private var fail: (Data) -> MockImage? {
        return { _ in nil }
    }
    
    private class ViewSpy<Image: Equatable>: FeedImageView {
        typealias Image = Image
        var message: FeedImageViewModel<Image>?
        
        func display(_ model: FeedImageViewModel<Image>) {
            self.message = model
        }
    }
    
    private struct MockImage: Equatable {}
}
