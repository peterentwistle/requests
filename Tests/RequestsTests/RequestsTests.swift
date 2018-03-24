//
//  RequestsTests.swift
//  RequestsTests
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
import XCTest
import Requests

class RequestsTests: XCTestCase {
    
    func testGet() {
        let expectation = XCTestExpectation(description: "Wait for get request")
        
        Requests.get("https://jsonplaceholder.typicode.com/posts/1") { response in
            XCTAssertTrue(response.text() != "")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testJsonDecoding() {
        struct Post: Codable {
            var userId: Int?
            var id: Int?
            var title: String?
            var body: String?
        }
        
        let expectation = XCTestExpectation(description: "Wait for get request")
        
        Requests.get("https://jsonplaceholder.typicode.com/posts/1") { response in
            let jsonResponse: Post? = response.json()
            XCTAssertTrue(jsonResponse != nil)
            XCTAssertTrue(jsonResponse!.id == 1)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testIp() {
        let expectation = XCTestExpectation(description: "Wait for get request")
        
        struct IP: Decodable {
            var origin: String
        }
        
        Requests.get("http://httpbin.org/ip") { response in
            let json: IP = response.json()
            XCTAssertTrue(json.origin != "")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testHeadersFromResponse() {
        let expectation = XCTestExpectation(description: "Wait for get request")
        
        Requests.get("http://httpbin.org/ip") { response in
            let headers = response.headers
            XCTAssertTrue(headers["Content-Type"] == "application/json")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testStatusCodeFromResponse() {
        let expectation = XCTestExpectation(description: "Wait for get request")
        
        Requests.get("http://httpbin.org/ip") { response in
            XCTAssertTrue(response.statusCode == 200)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
}
