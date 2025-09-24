//
//  Created by Dilshod Zopirov on 9/24/25.
//

import UIKit
import EssentialFeediOS

extension FeedViewController {
    
    class FakeRefreshControl: UIRefreshControl {
        var _isRefreshing: Bool = false
        
        override var isRefreshing: Bool { _isRefreshing }
        
        override func beginRefreshing() {
            _isRefreshing = true
        }
        
        override func endRefreshing() {
            _isRefreshing = false
        }
    }
    
}
