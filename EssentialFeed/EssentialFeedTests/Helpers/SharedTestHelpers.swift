//
//  SharedTestHelpers.swift
//  EssentialFeed
//
//  Created by Dilshod Zopirov on 9/5/25.
//

import Foundation
import EssentialFeed

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}
