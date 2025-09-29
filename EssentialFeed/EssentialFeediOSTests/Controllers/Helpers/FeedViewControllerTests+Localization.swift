//
//  Created by Dilshod Zopirov on 9/29/25.
//

import Foundation
import XCTest
import EssentialFeediOS

extension FeedViewControllerTests {
    func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedViewController.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if key == value {
            XCTFail("Missing localized string for key: \(key)", file: file, line: line)
        }
        
        return value
    }
}
