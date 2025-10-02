//
//  Created by Dilshod Zopirov on 10/2/25.
//

import XCTest

final class FeedImagePresenter {
    private let view: Any
    
    init(view: Any) {
        self.view = view
    }
}

final class FeedImagePresenterTests: XCTestCase {
    
    func test_init_doesNotMessageView() {
        let view = ViewSpy()
        let _ = FeedImagePresenter(view: view)
        
        XCTAssertEqual(view.messages.count, 0)
    }
    
    private class ViewSpy {
        var messages: [Any] = []
    }
}
