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

/// A type capable of performing an asynchronous data task for a URL request.
///
/// `URLSession` conforms to this protocol, so the live network stack is used by default.
public protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

public enum RequestError: Error, Equatable {
    case invalidURL
}

public struct Requests {}

private enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case head = "HEAD"
}

public protocol Requestable {
    /// Makes a GET request
    ///
    /// - Parameters:
    ///     - url: The String representation of the URL to make the request to.
    ///     - authentication: The authentication to be applied to the request
    ///     - session: The URL session to use for the request (defaults to `.shared`)
    /// - Returns: A Response object
    static func get(
        _ url: String,
        authentication: Authentication?,
        session: any URLSessionProtocol
    ) async throws -> Response
    
    /// Makes a POST request
    ///
    /// - Parameters:
    ///     - url: The String representation of the URL to make the request to.
    ///     - data: The data to pass in the body of the request.
    ///     - authentication: The authentication to be applied to the request
    ///     - session: The URL session to use for the request (defaults to `.shared`)
    /// - Returns: A Response object
    static func post(
        _ url: String,
        data: [String: String]?,
        authentication: Authentication?,
        session: any URLSessionProtocol
    ) async throws -> Response
    
    /// Makes a POST request
    ///
    /// - Parameters:
    ///     - url: The String representation of the URL to make the request to.
    ///     - json: The json object to pass in the body of the request.
    ///     - authentication: The authentication to be applied to the request
    ///     - session: The URL session to use for the request (defaults to `.shared`)
    /// - Returns: A Response object
    static func post<T: Encodable>(
        _ url: String,
        json: T,
        authentication: Authentication?,
        session: any URLSessionProtocol
    ) async throws -> Response
    
    /// Makes a PUT request
    ///
    /// - Parameters:
    ///     - url: The String representation of the URL to make the request to.
    ///     - data: The data to pass in the body of the request.
    ///     - authentication: The authentication to be applied to the request
    ///     - session: The URL session to use for the request (defaults to `.shared`)
    /// - Returns: A Response object
    static func put(
        _ url: String,
        data: [String: String]?,
        authentication: Authentication?,
        session: any URLSessionProtocol
    ) async throws -> Response
    
    /// Makes a PUT request
    ///
    /// - Parameters:
    ///     - url: The String representation of the URL to make the request to.
    ///     - json: The json object to pass in the body of the request.
    ///     - authentication: The authentication to be applied to the request
    ///     - session: The URL session to use for the request (defaults to `.shared`)
    /// - Returns: A Response object
    static func put<T: Encodable>(
        _ url: String,
        json: T,
        authentication: Authentication?,
        session: any URLSessionProtocol
    ) async throws -> Response
    
    /// Makes a PATCH request
    ///
    /// - Parameters:
    ///     - url: The String representation of the URL to make the request to.
    ///     - data: The data to pass in the body of the request.
    ///     - authentication: The authentication to be applied to the request
    ///     - session: The URL session to use for the request (defaults to `.shared`)
    /// - Returns: A Response object
    static func patch(
        _ url: String,
        data: [String: String]?,
        authentication: Authentication?,
        session: any URLSessionProtocol
    ) async throws -> Response
    
    /// Makes a PATCH request
    ///
    /// - Parameters:
    ///     - url: The String representation of the URL to make the request to.
    ///     - json: The json object to pass in the body of the request.
    ///     - authentication: The authentication to be applied to the request
    ///     - session: The URL session to use for the request (defaults to `.shared`)
    /// - Returns: A Response object
    static func patch<T: Encodable>(
        _ url: String,
        json: T,
        authentication: Authentication?,
        session: any URLSessionProtocol
    ) async throws -> Response
    
    /// Makes a DELETE request
    ///
    /// - Parameters:
    ///     - url: The String representation of the URL to make the request to.
    ///     - data: The data to pass in the body of the request.
    ///     - authentication: The authentication to be applied to the request
    ///     - session: The URL session to use for the request (defaults to `.shared`)
    /// - Returns: A Response object
    static func delete(
        _ url: String,
        data: [String: String]?,
        authentication: Authentication?,
        session: any URLSessionProtocol
    ) async throws -> Response
    
    /// Makes a DELETE request
    ///
    /// - Parameters:
    ///     - url: The String representation of the URL to make the request to.
    ///     - json: The json object to pass in the body of the request.
    ///     - authentication: The authentication to be applied to the request
    ///     - session: The URL session to use for the request (defaults to `.shared`)
    /// - Returns: A Response object
    static func delete<T: Encodable>(
        _ url: String,
        json: T,
        authentication: Authentication?,
        session: any URLSessionProtocol
    ) async throws -> Response
    
    /// Makes a HEAD request
    ///
    /// - Parameters:
    ///     - url: The String representation of the URL to make the request to.
    ///     - authentication: The authentication to be applied to the request
    ///     - session: The URL session to use for the request (defaults to `.shared`)
    /// - Returns: A Response object
    static func head(
        _ url: String,
        authentication: Authentication?,
        session: any URLSessionProtocol
    ) async throws -> Response
}

extension Requestable {
    private static func make(
        method: HttpMethod,
        url: String,
        data: [String: String]? = nil,
        json: Data? = nil,
        authentication: Authentication? = nil,
        session: any URLSessionProtocol = URLSession.shared
    ) async throws -> Response {
        guard let url = URL(string: url) else {
            throw RequestError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if let data = data {
            request.httpBody = data.bodyData()
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        }
        
        if let authentication = authentication {
            request.addAuthHeaders(authentication: authentication)
        }
        
        if let json = json {
            request.httpBody = json
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        let (data, response) = try await session.data(for: request)
        return (Response(url: url.absoluteString, data: data, response: response))
    }
    
    // MARK: - GET
    
    public static func get(
        _ url: String,
        authentication: Authentication? = nil,
        session: any URLSessionProtocol = URLSession.shared
    ) async throws -> Response {
        try await make(
            method: .get,
            url: url,
            authentication: authentication,
            session: session
        )
    }
    
    // MARK: - POST
    
    public static func post(
        _ url: String,
        data: [String: String]? = nil,
        authentication: Authentication? = nil,
        session: any URLSessionProtocol = URLSession.shared
    ) async throws -> Response {
        try await make(
            method: .post,
            url: url,
            data: data,
            authentication: authentication,
            session: session
        )
    }
    
    public static func post<T: Encodable>(
        _ url: String,
        json: T,
        authentication: Authentication? = nil,
        session: any URLSessionProtocol = URLSession.shared
    ) async throws -> Response {
        let jsonData = try JSONEncoder().encode(json)
        return try await make(
            method: .post,
            url: url,
            json: jsonData,
            authentication: authentication,
            session: session
        )
    }
    
    // MARK: - PUT
    
    public static func put(
        _ url: String,
        data: [String: String]? = nil,
        authentication: Authentication? = nil,
        session: any URLSessionProtocol = URLSession.shared
    ) async throws -> Response {
        try await make(
            method: .put,
            url: url,
            data: data,
            authentication: authentication,
            session: session
        )
    }
    
    public static func put<T: Encodable>(
        _ url: String,
        json: T,
        authentication: Authentication? = nil,
        session: any URLSessionProtocol = URLSession.shared
    ) async throws -> Response {
        let jsonData = try JSONEncoder().encode(json)
        return try await make(
            method: .put,
            url: url,
            json: jsonData,
            authentication: authentication,
            session: session
        )
    }
    
    // MARK: - PATCH
    
    public static func patch(
        _ url: String,
        data: [String: String]? = nil,
        authentication: Authentication? = nil,
        session: any URLSessionProtocol = URLSession.shared
    ) async throws -> Response {
        try await make(
            method: .patch,
            url: url,
            data: data,
            authentication: authentication,
            session: session
        )
    }
    
    public static func patch<T: Encodable>(
        _ url: String,
        json: T,
        authentication: Authentication? = nil,
        session: any URLSessionProtocol = URLSession.shared
    ) async throws -> Response {
        let jsonData = try JSONEncoder().encode(json)
        return try await make(
            method: .patch,
            url: url,
            json: jsonData,
            authentication: authentication,
            session: session
        )
    }
    
    // MARK: - DELETE
    
    public static func delete(
        _ url: String,
        data: [String: String]? = nil,
        authentication: Authentication? = nil,
        session: any URLSessionProtocol = URLSession.shared
    ) async throws -> Response {
        try await make(
            method: .delete,
            url: url,
            data: data,
            authentication: authentication,
            session: session
        )
    }
    
    public static func delete<T: Encodable>(
        _ url: String,
        json: T,
        authentication: Authentication? = nil,
        session: any URLSessionProtocol = URLSession.shared
    ) async throws -> Response {
        let jsonData = try JSONEncoder().encode(json)
        return try await make(
            method: .delete,
            url: url,
            json: jsonData,
            authentication: authentication,
            session: session
        )
    }
    
    // MARK: - HEAD
    
    public static func head(
        _ url: String,
        authentication: Authentication? = nil,
        session: any URLSessionProtocol = URLSession.shared
    ) async throws -> Response {
        try await make(
            method: .head,
            url: url,
            authentication: authentication,
            session: session
        )
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
        
        return data.joined(separator: "&").data(using: .utf8) ?? Data()
    }
}

// MARK: - addAuthHeaders
extension URLRequest {
    mutating func addAuthHeaders(authentication: Authentication) {
        self.addValue(authentication.authorizationHeader, forHTTPHeaderField: "Authorization")
    }
}
