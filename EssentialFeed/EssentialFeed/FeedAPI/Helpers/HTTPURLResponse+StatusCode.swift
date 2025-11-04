//
//  Created by Dilshod Zopirov on 11/4/25.
//

import Foundation

extension HTTPURLResponse {
    private var OK_200: Int { 200 }
    
    var isOK: Bool {
        return statusCode == OK_200
    }
}
