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

final class RequestsTests: XCTestCase {
    
    // MARK: - Mock session
    
    /// A `URLSessionProtocol` conformance that routes every `data(for:)` call
    /// through a closure, so tests never make real network requests.
    final class MockURLSession: URLSessionProtocol {
        private let handler: (URLRequest) async throws -> (Data, URLResponse)
        
        init(handler: @escaping (URLRequest) async throws -> (Data, URLResponse)) {
            self.handler = handler
        }
        
        func data(for request: URLRequest) async throws -> (Data, URLResponse) {
            try await handler(request)
        }
    }
    
    // MARK: - Helpers
    
    private func makeHTTPResponse(statusCode: Int = 200,
                                  headers: [String: String] = [:]) -> HTTPURLResponse {
        let url = URL(string: "http://localhost/")!
        return HTTPURLResponse(url: url,
                               statusCode: statusCode,
                               httpVersion: "HTTP/1.1",
                               headerFields: headers)!
    }
    
    private func makeSession(body: Data = Data(),
                             statusCode: Int = 200,
                             headers: [String: String] = [:]) -> MockURLSession {
        MockURLSession { _ in
            (body, self.makeHTTPResponse(statusCode: statusCode, headers: headers))
        }
    }
    
    // MARK: - GET
    
    func testGetReturnsStatusCode() async throws {
        let session = makeSession(body: Data("{\"id\":1}".utf8), statusCode: 200)
        let response = try await Requests.get("http://localhost/posts/1",
                                              session: session)
        
        XCTAssertEqual(200, try response.statusCode)
    }
    
    func testGetReturnsURL() async throws {
        let session = makeSession()
        let response = try await Requests.get("http://localhost/posts/1",
                                              session: session)
        
        XCTAssertEqual("http://localhost/posts/1", response.url)
    }
    
    func testGetReturnsText() async throws {
        let session = makeSession(body: Data("hello world".utf8))
        let response = try await Requests.get("http://localhost/",
                                              session: session)
        
        XCTAssertEqual("hello world", response.text)
    }
    
    func testGetReturnsHeaders() async throws {
        let session = makeSession(body: Data(), statusCode: 200, headers: ["Content-Type": "application/json"])
        let response = try await Requests.get("http://localhost/",
                                              session: session)
        
        XCTAssertEqual("application/json", response.headers["Content-Type"])
    }
    
    func testGetDecodesJSON() async throws {
        struct Post: Codable {
            var id: Int?
            var title: String?
        }
        
        let session = makeSession(body: Data("{\"id\":1,\"title\":\"Hello\"}".utf8))
        let response = try await Requests.get("http://localhost/posts/1",
                                              session: session)
        
        let post: Post = try response.json()
        XCTAssertEqual(1, post.id)
        XCTAssertEqual("Hello", post.title)
    }
    
    func testGetSetsHTTPMethod() async throws {
        var capturedRequest: URLRequest?
        let session = MockURLSession { request in
            capturedRequest = request
            return (Data(), self.makeHTTPResponse(statusCode: 200))
        }
        
        _ = try await Requests.get("http://localhost/",
                                   session: session)
        
        XCTAssertEqual("GET", capturedRequest?.httpMethod)
    }
    
    func testGetAppliesBearerAuthentication() async throws {
        var capturedRequest: URLRequest?
        let session = MockURLSession { request in
            capturedRequest = request
            return (Data(), self.makeHTTPResponse(statusCode: 200))
        }
        
        _ = try await Requests.get("http://localhost/bearer",
                                   authentication: BearerAuthentication(token: "abc123"),
                                   session: session)
        
        XCTAssertEqual("Bearer abc123", capturedRequest?.value(forHTTPHeaderField: "Authorization"))
    }
    
    func testGetReturnsNonSuccessStatusCode() async throws {
        let session = makeSession(body: Data(), statusCode: 404)
        let response = try await Requests.get("http://localhost/missing",
                                              session: session)
        
        XCTAssertEqual(404, try response.statusCode)
    }
    
    func testGetThrowsWhenSessionThrows() async {
        let session = MockURLSession { _ in
            throw URLError(.notConnectedToInternet)
        }
        
        do {
            _ = try await Requests.get("http://localhost/", session: session)
            XCTFail("Expected the request to throw")
        } catch let error as URLError {
            XCTAssertEqual(.notConnectedToInternet, error.code)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    // MARK: - POST
    
    func testPostWithFormData() async throws {
        var capturedRequest: URLRequest?
        let session = MockURLSession { request in
            capturedRequest = request
            return (Data("{\"form\":{\"key\":\"value\"}}".utf8), self.makeHTTPResponse(statusCode: 200))
        }
        
        let response = try await Requests.post("http://localhost/post",
                                               data: ["key": "value"],
                                               session: session)
        
        XCTAssertEqual(200, try response.statusCode)
        XCTAssertEqual("POST", capturedRequest?.httpMethod)
        XCTAssertEqual("key=value", String(data: capturedRequest?.httpBody ?? Data(), encoding: .utf8))
        
        let formTest: FormTest = try response.json()
        XCTAssertEqual("value", formTest.form.key)
    }
    
    func testPostWithJSONData() async throws {
        var capturedRequest: URLRequest?
        let session = MockURLSession { request in
            capturedRequest = request
            return (Data("{\"data\":\"raw-body\"}".utf8),
                    self.makeHTTPResponse(statusCode: 200,
                                          headers: ["Content-Type": "application/json"]))
        }
        
        let test = Test(value: "Test123")
        let response = try await Requests.post("http://localhost/post",
                                               json: test,
                                               session: session)
        
        XCTAssertEqual(200, try response.statusCode)
        XCTAssertEqual("application/json", capturedRequest?.value(forHTTPHeaderField: "Content-Type"))
        XCTAssertEqual(Data("{\"value\":\"Test123\"}".utf8), capturedRequest?.httpBody)
        
        let json: DataTest = try response.json()
        XCTAssertEqual("raw-body", json.data)
    }
    
    func testPostWithNoData() async throws {
        let session = makeSession(body: Data(), statusCode: 200)
        let response = try await Requests.post("http://localhost/post",
                                               session: session)
        
        XCTAssertEqual(200, try response.statusCode)
    }
    
    // MARK: - PUT
    
    func testPutWithData() async throws {
        var capturedRequest: URLRequest?
        let session = MockURLSession { request in
            capturedRequest = request
            return (Data("{\"data\":\"key=value\"}".utf8), self.makeHTTPResponse(statusCode: 200))
        }
        
        let response = try await Requests.put("http://localhost/put",
                                              data: ["key": "value"],
                                              session: session)
        
        XCTAssertEqual(200, try response.statusCode)
        XCTAssertEqual("PUT", capturedRequest?.httpMethod)
        XCTAssertEqual("key=value", String(data: capturedRequest?.httpBody ?? Data(), encoding: .utf8))
        
        let json: DataTest = try response.json()
        XCTAssertEqual("key=value", json.data)
    }
    
    func testPutWithNoData() async throws {
        let session = makeSession(body: Data(), statusCode: 200)
        let response = try await Requests.put("http://localhost/put",
                                              session: session)
        
        XCTAssertEqual(200, try response.statusCode)
    }
    
    func testPutWithJSONData() async throws {
        var capturedRequest: URLRequest?
        let session = MockURLSession { request in
            capturedRequest = request
            return (Data("{\"data\":\"raw-body\"}".utf8), self.makeHTTPResponse(statusCode: 200))
        }
        
        let test = Test(value: "Test123")
        let response = try await Requests.put("http://localhost/put",
                                              json: test,
                                              session: session)
        
        XCTAssertEqual(200, try response.statusCode)
        XCTAssertEqual(Data("{\"value\":\"Test123\"}".utf8), capturedRequest?.httpBody)
        
        let json: DataTest = try response.json()
        XCTAssertEqual("raw-body", json.data)
    }
    
    // MARK: - PATCH
    
    func testPatchWithData() async throws {
        var capturedRequest: URLRequest?
        let session = MockURLSession { request in
            capturedRequest = request
            return (Data("{\"data\":\"key=value\"}".utf8), self.makeHTTPResponse(statusCode: 200))
        }
        
        let response = try await Requests.patch("http://localhost/patch",
                                                data: ["key": "value"],
                                                session: session)
        
        XCTAssertEqual(200, try response.statusCode)
        XCTAssertEqual("PATCH", capturedRequest?.httpMethod)
        XCTAssertEqual("key=value", String(data: capturedRequest?.httpBody ?? Data(), encoding: .utf8))
        
        let json: DataTest = try response.json()
        XCTAssertEqual("key=value", json.data)
    }
    
    func testPatchWithNoData() async throws {
        let session = makeSession(body: Data(), statusCode: 200)
        let response = try await Requests.patch("http://localhost/patch",
                                                session: session)
        
        XCTAssertEqual(200, try response.statusCode)
    }
    
    func testPatchWithJSONData() async throws {
        var capturedRequest: URLRequest?
        let session = MockURLSession { request in
            capturedRequest = request
            return (Data("{\"data\":\"raw-body\"}".utf8), self.makeHTTPResponse(statusCode: 200))
        }
        
        let test = Test(value: "Test123")
        let response = try await Requests.patch("http://localhost/patch",
                                                json: test,
                                                session: session)
        
        XCTAssertEqual(200, try response.statusCode)
        XCTAssertEqual(Data("{\"value\":\"Test123\"}".utf8), capturedRequest?.httpBody)
        
        let json: DataTest = try response.json()
        XCTAssertEqual("raw-body", json.data)
    }
    
    // MARK: - DELETE
    
    func testDeleteWithData() async throws {
        var capturedRequest: URLRequest?
        let session = MockURLSession { request in
            capturedRequest = request
            return (Data("{\"data\":\"key=value\"}".utf8), self.makeHTTPResponse(statusCode: 200))
        }
        
        let response = try await Requests.delete("http://localhost/delete",
                                                 data: ["key": "value"],
                                                 session: session)
        
        XCTAssertEqual(200, try response.statusCode)
        XCTAssertEqual("DELETE", capturedRequest?.httpMethod)
        XCTAssertEqual("key=value", String(data: capturedRequest?.httpBody ?? Data(), encoding: .utf8))
        
        let json: DataTest = try response.json()
        XCTAssertEqual("key=value", json.data)
    }
    
    func testDeleteWithNoData() async throws {
        let session = makeSession(body: Data(), statusCode: 200)
        let response = try await Requests.delete("http://localhost/delete",
                                                 session: session)
        
        XCTAssertEqual(200, try response.statusCode)
    }
    
    func testDeleteWithJSONData() async throws {
        var capturedRequest: URLRequest?
        let session = MockURLSession { request in
            capturedRequest = request
            return (Data("{\"data\":\"raw-body\"}".utf8), self.makeHTTPResponse(statusCode: 200))
        }
        
        let test = Test(value: "Test123")
        let response = try await Requests.delete("http://localhost/delete",
                                                 json: test,
                                                 session: session)
        
        XCTAssertEqual(200, try response.statusCode)
        XCTAssertEqual(Data("{\"value\":\"Test123\"}".utf8), capturedRequest?.httpBody)
        
        let json: DataTest = try response.json()
        XCTAssertEqual("raw-body", json.data)
    }
    // MARK: - Response Error Tests
    
    func testStatusCodeThrowsWhenNotHTTP() async throws {
        let url = URL(string: "file:///tmp/test.txt")!
        let response = Response(url: url.absoluteString,
                                data: nil,
                                response: URLResponse(url: url,
                                                      mimeType: nil,
                                                      expectedContentLength: 0,
                                                      textEncodingName: nil))
        
        do {
            _ = try response.statusCode
            XCTFail("Expected statusCode to throw error")
        } catch let error as ResponseError {
            XCTAssertEqual(error, .invalidResponse)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testJSONThrowsWhenNoData() async throws {
        let response = Response(url: "http://localhost",
                                data: nil,
                                response: nil)
        
        do {
            let _: DataTest = try response.json()
            XCTFail("Expected json() to throw error")
        } catch let error as ResponseError {
            XCTAssertEqual(error, .noData)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testJSONThrowsOnMalformedJSON() async throws {
        let response = Response(url: "http://localhost",
                                data: Data("invalid json".utf8),
                                response: nil)
        
        do {
            let _: DataTest = try response.json()
            XCTFail("Expected json() to throw error")
        } catch is DecodingError {
            // Success
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testHeadersReturnsEmptyWhenResponseIsNil() async {
        let response = Response(url: "http://localhost",
                                data: nil,
                                response: nil)
        
        XCTAssertEqual(response.headers, [:])
    }

    // MARK: - Edge Case Tests

    func testDictionaryBodyDataWithEmptyDictionary() {
        let dict: [String: String] = [:]
        let data = dict.bodyData()
        
        XCTAssertTrue(data.isEmpty)
    }

    func testDictionaryBodyDataWithSpecialCharacters() {
        let dict = ["key": "val&ue"]
        let data = dict.bodyData()
        
        XCTAssertEqual(String(data: data, encoding: .utf8), "key=val&ue")
    }

    // MARK: - invalidURL Test

    func testGetWithInvalidURL() async {
        do {
            _ = try await Requests.get("", session: makeSession())
            XCTFail("Expected the request to throw an error for an invalid URL")
        } catch let error as RequestError {
            XCTAssertEqual(error, .invalidURL)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}

fileprivate struct FormTest: Decodable {
    let form: Form
}

fileprivate struct Form: Decodable {
    let key: String
}

fileprivate struct Test: Encodable {
    let value: String
}

fileprivate struct DataTest: Decodable {
    let data: String
}
