//
//  Created by Dilshod Zopirov on 10/2/25.
//

import UIKit

extension UIRefreshControl {
    func update(_ isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
