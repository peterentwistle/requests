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

public class Requests {
}

protocol Getable {
    static func get(_ url: String, completionHandler: @escaping (Response) -> ())
}

protocol Postable {
    static func post(_ url: String, data: [String: String], completionHandler: @escaping (Response) -> ())
}

// MARK: - Getable

extension Requests: Getable {
    public static func get(_ url: String, completionHandler: @escaping (Response) -> ()) {
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            if let data = data {
                completionHandler(Response(url: url, data: data, response: response, error: error))
            }
        }.resume()
    }
}

// MARK: - Postable

extension Requests: Postable {
    public static func post(_ url: String, data: [String : String], completionHandler: @escaping (Response) -> ()) {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = data.bodyData()
            
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                completionHandler(Response(url: url, data: data, response: response, error: error))
            }
        }.resume()
    }
}

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
