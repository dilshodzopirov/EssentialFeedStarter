//
//  Created by Dilshod Zopirov on 10/2/25.
//

import UIKit

public final class ErrorView: UIView {
    private let label = UILabel()
    public var message: String? {
        get { isVisible ? label.text : nil }
        set { setMessageAnimated(newValue) }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideMessageAnimated)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var isVisible: Bool {
        return self.alpha > 0
    }
    
    private func setMessageAnimated(_ message: String?) {
        if let message {
            showAnimated(message)
        } else {
            hideMessageAnimated()
        }
    }
    
    private func showAnimated(_ message: String) {
        label.text = message
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
    
    @objc private func hideMessageAnimated() {
        UIView.animate(
            withDuration: 0.25,
            animations: { self.alpha = 0 },
            completion: { completed in
                if completed { self.label.text = nil }
            }
        )
    }
}
