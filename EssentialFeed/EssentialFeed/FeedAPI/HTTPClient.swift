//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Dilshod Zopirov on 8/23/25.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
