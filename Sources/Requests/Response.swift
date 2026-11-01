//
//  Response.swift
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

public struct Response: Sendable {
    public var url: String?
    public var data: Data?
    public var response: URLResponse?
    
    public init(
        url: String? = nil,
        data: Data? = nil,
        response: URLResponse? = nil
    ) {
        self.url = url
        self.data = data
        self.response = response
    }
}

/// Errors that can occur during Response processing.
public enum ResponseError: Error, Equatable {
    case noData
    case invalidResponse
}

public protocol Printable {
    var text: String? { get }
}

public protocol JSONDecodable {
    func json<T: Decodable>() throws -> T
}

public protocol HTTPResponse {
    var headers: [String: String] { get }
    var statusCode: Int { get throws }
}

// MARK: - Printable
extension Response: Printable {
    public var text: String? {
        guard let data = data else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

// MARK: - JSONDecodable
extension Response: JSONDecodable {
    public func json<T: Decodable>() throws -> T {
        guard let data = data else {
            throw ResponseError.noData
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}

// MARK: - HTTPResponse
extension Response: HTTPResponse {
    public var headers: [String: String] {
        return (response as? HTTPURLResponse)?.allHeaderFields as? [String: String] ?? [:]
    }
    
    public var statusCode: Int {
        get throws {
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ResponseError.invalidResponse
            }
            return httpResponse.statusCode
        }
    }
}
