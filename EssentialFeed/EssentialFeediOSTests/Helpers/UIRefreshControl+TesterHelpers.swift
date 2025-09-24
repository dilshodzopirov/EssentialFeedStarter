//
//  Created by Dilshod Zopirov on 9/24/25.
//

import UIKit

extension UIRefreshControl {
    func simulatePullRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
