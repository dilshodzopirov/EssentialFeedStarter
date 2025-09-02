//
//  XCTestCase+MemoryLeakTracking.swift
//  EssentialFeed
//
//  Created by Dilshod Zopirov on 8/27/25.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated, potential memory leak.", file: file, line: line)
        }
    }
}
