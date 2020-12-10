//
//  Requests.swift
//  Requests
//
//  Copyright 2018 Peter Entwistle
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

public struct Requests {}

private enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

public protocol Requestable {
    /// Makes a GET request
    ///
    /// - Parameters:
    ///     - url: The String representation of the URL to make the request to.
    ///     - authentication: The authentication to be applied to the request
    ///     - completionHandler: The completion handler to call when the request has completed.
    static func get(_ url: String, authentication: Authentication?, completionHandler: @escaping (Response) -> ())
    
    /// Makes a POST request
    ///
    /// - Parameters:
    ///     - url: The String representation of the URL to make the request to.
    ///     - data: The data to pass in the body of the request.
    ///     - authentication: The authentication to be applied to the request
    ///     - completionHandler: The completion handler to call when the request has completed.
    static func post(_ url: String, data: [String: String]?, authentication: Authentication?, completionHandler: @escaping (Response) -> ())
    
    /// Makes a POST request
    ///
    /// - Parameters:
    ///     - url: The String representation of the URL to make the request to.
    ///     - json: The json data to pass in the body of the request.
    ///     - authentication: The authentication to be applied to the request
    ///     - completionHandler: The completion handler to call when the request has completed.
    static func post(_ url: String, json: Data?, authentication: Authentication?, completionHandler: @escaping (Response) -> ())
    
    /// Makes a PUT request
    ///
    /// - Parameters:
    ///     - url: The String representation of the URL to make the request to.
    ///     - data: The data to pass in the body of the request.
    ///     - authentication: The authentication to be applied to the request
    ///     - completionHandler: The completion handler to call when the request has completed.
    static func put(_ url: String, data: [String: String]?, authentication: Authentication?, completionHandler: @escaping (Response) -> ())
    
    /// Makes a PATCH request
    ///
    /// - Parameters:
    ///     - url: The String representation of the URL to make the request to.
    ///     - data: The data to pass in the body of the request.
    ///     - authentication: The authentication to be applied to the request
    ///     - completionHandler: The completion handler to call when the request has completed.
    static func patch(_ url: String, data: [String: String]?, authentication: Authentication?, completionHandler: @escaping (Response) -> ())
    
    /// Makes a DELETE request
    ///
    /// - Parameters:
    ///     - url: The String representation of the URL to make the request to.
    ///     - data: The data to pass in the body of the request.
    ///     - authentication: The authentication to be applied to the request
    ///     - completionHandler: The completion handler to call when the request has completed.
    static func delete(_ url: String, data: [String: String]?, authentication: Authentication?, completionHandler: @escaping (Response) -> ())
}

extension Requestable {
    private static func make(method: HttpMethod, url: String, data: [String: String]? = nil, json: Data? = nil, authentication: Authentication? = nil, completionHandler: @escaping (Response) -> ()) {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = method.rawValue
        
        if let data = data {
            request.httpBody = data.bodyData()
        }
        
        if let authentication = authentication {
            request.addAuthHeaders(authentication: authentication)
        }
        
        if let json = json {
            request.httpBody = json
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                completionHandler(Response(url: url, data: data, response: response, error: error))
            }
        }.resume()
    }
    
    public static func get(_ url: String, authentication: Authentication? = nil, completionHandler: @escaping (Response) -> ()) {
        make(method: .get, url: url, data: nil, authentication: authentication) { response in
            completionHandler(response)
        }
    }
    
    public static func post(_ url: String, data: [String : String]? = nil, authentication: Authentication? = nil, completionHandler: @escaping (Response) -> ()) {
        make(method: .post, url: url, data: data, authentication: authentication) { response in
            completionHandler(response)
        }
    }
    
    public static func post(_ url: String, json: Data?, authentication: Authentication? = nil, completionHandler: @escaping (Response) -> ()) {
        make(method: .post, url: url, json: json, authentication: authentication) { response in
            completionHandler(response)
        }
    }
    
    public static func put(_ url: String, data: [String : String]? = nil, authentication: Authentication? = nil, completionHandler: @escaping (Response) -> ()) {
        make(method: .put, url: url, data: data, authentication: authentication) { response in
            completionHandler(response)
        }
    }
    
    public static func patch(_ url: String, data: [String : String]? = nil, authentication: Authentication? = nil, completionHandler: @escaping (Response) -> ()) {
        make(method: .patch, url: url, data: data, authentication: authentication) { response in
            completionHandler(response)
        }
    }
    
    public static func delete(_ url: String, data: [String : String]? = nil, authentication: Authentication? = nil, completionHandler: @escaping (Response) -> ()) {
        make(method: .delete, url: url, data: data, authentication: authentication) { response in
            completionHandler(response)
        }
    }
}

extension Requests: Requestable {}

// MARK: - Dictionary<String, String>
extension Dictionary where Key == String, Value == String {
    func bodyData() -> Data {
        var data = [String]()
        
        for (key, value) in self {
            data.append("\(key)=\(value)")
        }
        
        return data.joined(separator: "&").data(using: .utf8)!
    }
}

// MARK: - addAuthHeaders
extension URLRequest {
    mutating func addAuthHeaders(authentication: Authentication) {
        self.addValue(authentication.authorizationHeader, forHTTPHeaderField: "Authorization")
    }
}
