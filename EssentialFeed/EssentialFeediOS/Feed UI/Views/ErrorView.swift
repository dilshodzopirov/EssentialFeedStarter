//
//  Created by Dilshod Zopirov on 10/2/25.
//

import UIKit

public final class ErrorView: UIView {
    private let label = UILabel()
    public var message: String? {
        get { label.text }
        set { label.text = newValue }
    }
    
    
}
