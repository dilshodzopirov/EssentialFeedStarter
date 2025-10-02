//
//  Created by Dilshod Zopirov on 10/2/25.
//

import XCTest

final class FeedPresenter {
    private let view: Any
    
    init(view: Any) {
        self.view = view
    }
}

final class FeedPresenterTests: XCTestCase {
        
    func test_init_doesNotMessageUponCreation() {
        let view = ViewSpy()
        let _ = FeedPresenter(view: view)
        
        XCTAssertEqual(view.messages.count, 0)
    }
    
    private class ViewSpy {
        var messages: [Any] = []
    }
    
}
