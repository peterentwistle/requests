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

public struct Response {
    public var url: String?
    public var data: Data?
    public var response: URLResponse?
    public var error: Error?
}

public protocol Printable {
    func text() -> String
}

public protocol JSONDecodable {
    func json() -> String
}

public protocol HTTPResponse {
    var headers: [String: String] { get }
    var statusCode: Int { get }
}

// MARK: - Printable

extension Response: Printable {
    public func text() -> String {
        return NSString(data: data!, encoding: String.Encoding.utf8.rawValue)! as String
    }
}

// MARK: - JSONDecodable

extension Response: JSONDecodable {
    public func json<T: Decodable>() -> T {
        return try! JSONDecoder().decode(T.self, from: data!)
    }
}

// MARK: - HTTPResponse

extension Response: HTTPResponse {
    public var headers: [String : String] {
        return (response as! HTTPURLResponse).allHeaderFields as! [String: String]
    }
    
    public var statusCode: Int {
        return (response as! HTTPURLResponse).statusCode
    }
}
