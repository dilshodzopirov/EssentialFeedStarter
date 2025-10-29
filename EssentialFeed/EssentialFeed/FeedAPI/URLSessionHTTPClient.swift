//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Dilshod Zopirov on 8/28/25.
//

import Foundation

public final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnexpectedValuesRepresentation: Error {}
    
    private struct URLSessionTaskWrapper: HTTPClientTask {
        let wrapper: URLSessionTask
        
        func cancel() {
            wrapper.cancel()
        }
    }
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        let task = session.dataTask(with: url, completionHandler: { data, response, error in
            completion(Result {
                if let data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else if let error {
                    throw error
                } else {
                    throw UnexpectedValuesRepresentation()
                }
            })
        })
        task.resume()
        return URLSessionTaskWrapper(wrapper: task)
    }
}
