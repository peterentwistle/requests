//
//  Authentication.swift
//  Requests
//
//  Copyright 2020 Peter Entwistle
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

public protocol Authentication {
    var token: String { get }
    var authorizationHeader: String { get }
}

// MARK: - BearerAuthentication
public struct BearerAuthentication: Authentication {
    public let token: String
    public var authorizationHeader: String { "Bearer \(token)" }
    
    public init(token: String) {
        self.token = token
    }
}
