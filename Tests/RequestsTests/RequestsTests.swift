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

import XCTest
@testable import Requests

class RequestsTests: XCTestCase {
    func testJsonDecoding() async {
        struct Post: Codable {
            var userId: Int?
            var id: Int?
            var title: String?
            var body: String?
        }
        
        let response = try! await Requests.get("https://jsonplaceholder.typicode.com/posts/1")
        let jsonResponse: Post = response.json()
    
        XCTAssertNotNil(jsonResponse)
        XCTAssertEqual(1, jsonResponse.id)
    }
    
    func testIp() async {
        struct IP: Decodable {
            var origin: String
        }
        
        let response = try! await Requests.get("http://httpbin.org/ip")
        let json: IP = response.json()
        
        XCTAssertTrue(json.origin != "")
    }
    
    func testHeadersFromResponse() async {
        let response = try! await Requests.get("http://httpbin.org/ip")
        let headers = response.headers
        
        XCTAssertEqual("application/json", headers["Content-Type"])
    }
    
    func testStatusCodeFromResponse() async {
        let response = try! await Requests.get("http://httpbin.org/ip")
        
        XCTAssertEqual(200, response.statusCode)
    }
    
    // MARK: GET
    func testGet() async {
        let response = try! await Requests.get("http://httpbin.org/get")
        
        XCTAssertEqual(200, response.statusCode)
    }
    
    func testGetText() async {
        let response = try! await Requests.get("http://httpbin.org/ip")
        
        XCTAssertTrue(response.text != "")
    }
    
    func testGetWithBearerAuth() async {
        let response = try! await Requests.get("https://httpbin.org/bearer",
                                               authentication: BearerAuthentication(token: "1234"))
        
        XCTAssertEqual(200, response.statusCode)
    }
    
    // MARK: POST
    func testPostWithData() async {
        let response = try! await Requests.post("http://httpbin.org/post", data: ["key": "value"])
        XCTAssertEqual(200, response.statusCode)
        
        let formTest: FormTest = response.json()
        XCTAssertEqual("value", formTest.form.key)
    }
    
    func testPostWithNoData() async {
        let response = try! await Requests.post("http://httpbin.org/post")
        
        XCTAssertEqual(200, response.statusCode)
    }
    
    func testPostWithJsonData() async {
        let test = Test(value: "Test123")
        let encoder = JSONEncoder()
        let jsonData = try? encoder.encode(test)
        
        let response = try! await Requests.post("http://httpbin.org/post", json: jsonData)
        XCTAssertEqual(200, response.statusCode)
        
        let dataTest: DataTest = response.json()
        XCTAssertEqual("{\"value\":\"Test123\"}", dataTest.data)
    }
    
    // MARK: PUT
    func testPutWithData() async {
        let response = try! await Requests.put("http://httpbin.org/put", data: ["key": "value"])
        XCTAssertEqual(200, response.statusCode)
        
        let dataTest: DataTest = response.json()
        XCTAssertEqual("key=value", dataTest.data)
    }
        
    func testPutWithNoData() async {
        let response = try! await  Requests.put("http://httpbin.org/put")
        
        XCTAssertEqual(200, response.statusCode)
    }
    
    // MARK: PATCH
    func testPatchWithData() async {
        let response = try! await Requests.patch("http://httpbin.org/patch", data: ["key": "value"])
        XCTAssertEqual(200, response.statusCode)
        
        let json: DataTest = response.json()
        XCTAssertEqual("key=value", json.data)
    }
    
    func testPatchWithNoData() async {
        let response = try! await Requests.patch("http://httpbin.org/patch")
        
        XCTAssertEqual(200, response.statusCode)
    }
    
    // MARK: DELETE
    func testDeleteWithData() async {
        let response = try! await Requests.delete("http://httpbin.org/delete", data: ["key": "value"])
        XCTAssertEqual(200, response.statusCode)
        
        let json: DataTest = response.json()
        XCTAssertEqual("key=value", json.data)
    }
    
    func testDeleteWithNoData() async {
        let response = try! await Requests.delete("http://httpbin.org/delete")
        
        XCTAssertEqual(200, response.statusCode)
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
