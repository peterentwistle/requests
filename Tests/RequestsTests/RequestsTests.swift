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
            XCTAssertNotNil(jsonResponse)
            XCTAssertEqual(1, jsonResponse!.id)
            
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
            XCTAssertEqual("application/json", headers["Content-Type"])
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testStatusCodeFromResponse() {
        let expectation = XCTestExpectation(description: "Wait for get request")
        Requests.get("http://httpbin.org/ip") { response in
            XCTAssertEqual(200, response.statusCode)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGet() {
        let expectation = XCTestExpectation(description: "Wait for get request")
        
        Requests.get("http://httpbin.org/get") { response in
            XCTAssertEqual(200, response.statusCode)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetText() {
        let expectation = XCTestExpectation(description: "Wait for get request")
        
        Requests.get("http://httpbin.org/ip") { response in
            XCTAssertTrue(response.text != "")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testPostWithData() {
        let expectation = XCTestExpectation(description: "Wait for post request")
        
        Requests.post("http://httpbin.org/post", data: ["key": "value"]) { response in
            XCTAssertEqual(200, response.statusCode)
            
            let formTest: FormTest = response.json()
            XCTAssertEqual("value", formTest.form.key)

            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testPostWithNoData() {
        let expectation = XCTestExpectation(description: "Wait for post request")
        
        Requests.post("http://httpbin.org/post") { response in
            XCTAssertEqual(200, response.statusCode)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testPostWithJsonData() {
        let expectation = XCTestExpectation(description: "Wait for post request")
        
        let test = Test(value: "Test123")
        
        let encoder = JSONEncoder()
        let jsonData = try? encoder.encode(test)
        
        Requests.post("http://httpbin.org/post", json: jsonData) { response in
            XCTAssertEqual(200, response.statusCode)
            
            let dataTest: DataTest = response.json()
            XCTAssertEqual("{\"value\":\"Test123\"}", dataTest.data)

            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testPutWithData() {
        let expectation = XCTestExpectation(description: "Wait for put request")
        
        Requests.put("http://httpbin.org/put", data: ["key": "value"]) { response in
            XCTAssertEqual(200, response.statusCode)
            
            let dataTest: DataTest = response.json()
            XCTAssertEqual("key=value", dataTest.data)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testPutWithNoData() {
        let expectation = XCTestExpectation(description: "Wait for put request")
        
        Requests.put("http://httpbin.org/put") { response in
            XCTAssertEqual(200, response.statusCode)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testPatchWithData() {
        let expectation = XCTestExpectation(description: "Wait for patch request")
        
        Requests.patch("http://httpbin.org/patch", data: ["key": "value"]) { response in
            XCTAssertEqual(200, response.statusCode)
            
            let json: DataTest = response.json()
            XCTAssertEqual("key=value", json.data)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testPatchWithNoData() {
        let expectation = XCTestExpectation(description: "Wait for patch request")
        
        Requests.patch("http://httpbin.org/patch") { response in
            XCTAssertEqual(200, response.statusCode)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testDeleteWithData() {
        let expectation = XCTestExpectation(description: "Wait for delete request")
        
        Requests.delete("http://httpbin.org/delete", data: ["key": "value"]) { response in
            XCTAssertEqual(200, response.statusCode)
            
            let json: DataTest = response.json()
            XCTAssertEqual("key=value", json.data)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testDeleteWithNoData() {
        let expectation = XCTestExpectation(description: "Wait for delete request")
        
        Requests.delete("http://httpbin.org/delete") { response in
            XCTAssertEqual(200, response.statusCode)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
}

fileprivate struct FormTest: Decodable {
    let form: Form
}

fileprivate struct Form: Decodable {
    let key: String
}

fileprivate struct DataTest: Decodable {
    let data: String
}

fileprivate struct Test: Codable {
    let value: String
}
