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

import Testing
import Foundation
@testable import Requests

@Suite struct RequestsTests {
    
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
    
    @Test func getReturnsStatusCode() async throws {
        // Given
        let session = makeSession(body: Data("{\"id\":1}".utf8), statusCode: 200)
        
        // When
        let response = try await Requests.get("http://localhost/posts/1",
                                              session: session)
        
        // Then
        #expect(try response.statusCode == 200)
    }
    
    @Test func getReturnsURL() async throws {
        // Given
        let session = makeSession()
        
        // When
        let response = try await Requests.get("http://localhost/posts/1",
                                              session: session)
        
        // Then
        #expect(response.url == "http://localhost/posts/1")
    }
    
    @Test func getReturnsText() async throws {
        // Given
        let session = makeSession(body: Data("hello world".utf8))
        
        // When
        let response = try await Requests.get("http://localhost/",
                                              session: session)
        
        // Then
        #expect(response.text == "hello world")
    }
    
    @Test func getReturnsHeaders() async throws {
        // Given
        let session = makeSession(body: Data(), statusCode: 200, headers: ["Content-Type": "application/json"])
        
        // When
        let response = try await Requests.get("http://localhost/",
                                              session: session)
        
        // Then
        #expect(response.headers["Content-Type"] == "application/json")
    }
    
    @Test func getDecodesJSON() async throws {
        struct Post: Codable {
            var id: Int?
            var title: String?
        }
        
        // Given
        let session = makeSession(body: Data("{\"id\":1,\"title\":\"Hello\"}".utf8))
        
        // When
        let response = try await Requests.get("http://localhost/posts/1",
                                              session: session)
        
        // Then
        let post: Post = try response.json()
        #expect(post.id == 1)
        #expect(post.title == "Hello")
    }
    
    @Test func getSetsHTTPMethod() async throws {
        // Given
        var capturedRequest: URLRequest?
        let session = MockURLSession { request in
            capturedRequest = request
            return (Data(), self.makeHTTPResponse(statusCode: 200))
        }
        
        // When
        _ = try await Requests.get("http://localhost/",
                                   session: session)
        
        // Then
        #expect(capturedRequest?.httpMethod == "GET")
    }
    
    @Test func getAppliesBearerAuthentication() async throws {
        // Given
        var capturedRequest: URLRequest?
        let session = MockURLSession { request in
            capturedRequest = request
            return (Data(), self.makeHTTPResponse(statusCode: 200))
        }
        
        // When
        _ = try await Requests.get("http://localhost/bearer",
                                   authentication: BearerAuthentication(token: "abc123"),
                                   session: session)
        
        // Then
        #expect(capturedRequest?.value(forHTTPHeaderField: "Authorization") == "Bearer abc123")
    }
    
    @Test func getReturnsNonSuccessStatusCode() async throws {
        // Given
        let session = makeSession(body: Data(), statusCode: 404)
        
        // When
        let response = try await Requests.get("http://localhost/missing",
                                              session: session)
        
        // Then
        #expect(try response.statusCode == 404)
    }
    
    @Test func getThrowsWhenSessionThrows() async throws {
        // Given
        let session = MockURLSession { _ in
            throw URLError(.notConnectedToInternet)
        }
        
        await #expect(throws: URLError(.notConnectedToInternet)) {
            _ = try await Requests.get("http://localhost/", session: session)
        }
    }
    
    // MARK: - POST
    
    @Test func postWithFormData() async throws {
        // Given
        var capturedRequest: URLRequest?
        let session = MockURLSession { request in
            capturedRequest = request
            return (Data("{\"form\":{\"key\":\"value\"}}".utf8), self.makeHTTPResponse(statusCode: 200))
        }
        
        // When
        let response = try await Requests.post("http://localhost/post",
                                               data: ["key": "value"],
                                               session: session)
        
        // Then
        #expect(try response.statusCode == 200)
        #expect(capturedRequest?.httpMethod == "POST")
        #expect(String(data: capturedRequest?.httpBody ?? Data(), encoding: .utf8) == "key=value")
        
        let formTest: FormTest = try response.json()
        #expect(formTest.form.key == "value")
    }
    
    @Test func postWithJSONData() async throws {
        // Given
        var capturedRequest: URLRequest?
        let session = MockURLSession { request in
            capturedRequest = request
            return (Data("{\"data\":\"raw-body\"}".utf8),
                    self.makeHTTPResponse(statusCode: 200,
                                          headers: ["Content-Type": "application/json"]))
        }
        
        // When
        let test = Test(value: "Test123")
        let response = try await Requests.post("http://localhost/post",
                                               json: test,
                                               session: session)
        
        // Then
        #expect(try response.statusCode == 200)
        #expect(capturedRequest?.value(forHTTPHeaderField: "Content-Type") == "application/json")
        #expect(capturedRequest?.httpBody == Data("{\"value\":\"Test123\"}".utf8))
        
        let json: DataTest = try response.json()
        #expect(json.data == "raw-body")
    }
    
    @Test func postWithNoData() async throws {
        // Given
        let session = makeSession(body: Data(), statusCode: 200)
        
        // When
        let response = try await Requests.post("http://localhost/post",
                                               session: session)
        
        // Then
        #expect(try response.statusCode == 200)
    }
    
    // MARK: - PUT
    
    @Test func putWithData() async throws {
        // Given
        var capturedRequest: URLRequest?
        let session = MockURLSession { request in
            capturedRequest = request
            return (Data("{\"data\":\"key=value\"}".utf8), self.makeHTTPResponse(statusCode: 200))
        }
        
        // When
        let response = try await Requests.put("http://localhost/put",
                                              data: ["key": "value"],
                                              session: session)
        
        // Then
        #expect(try response.statusCode == 200)
        #expect(capturedRequest?.httpMethod == "PUT")
        #expect(String(data: capturedRequest?.httpBody ?? Data(), encoding: .utf8) == "key=value")
        
        let json: DataTest = try response.json()
        #expect(json.data == "key=value")
    }
    
    @Test func putWithNoData() async throws {
        // Given
        let session = makeSession(body: Data(), statusCode: 200)
        
        // When
        let response = try await Requests.put("http://localhost/put",
                                              session: session)
        
        // Then
        #expect(try response.statusCode == 200)
    }
    
    @Test func putWithJSONData() async throws {
        // Given
        var capturedRequest: URLRequest?
        let session = MockURLSession { request in
            capturedRequest = request
            return (Data("{\"data\":\"raw-body\"}".utf8), self.makeHTTPResponse(statusCode: 200))
        }
        
        // When
        let test = Test(value: "Test123")
        let response = try await Requests.put("http://localhost/put",
                                              json: test,
                                              session: session)
        
        // Then
        #expect(try response.statusCode == 200)
        #expect(capturedRequest?.httpBody == Data("{\"value\":\"Test123\"}".utf8))
        
        let json: DataTest = try response.json()
        #expect(json.data == "raw-body")
    }
    
    // MARK: - PATCH
    
    @Test func patchWithData() async throws {
        // Given
        var capturedRequest: URLRequest?
        let session = MockURLSession { request in
            capturedRequest = request
            return (Data("{\"data\":\"key=value\"}".utf8), self.makeHTTPResponse(statusCode: 200))
        }
        
        // When
        let response = try await Requests.patch("http://localhost/patch",
                                                data: ["key": "value"],
                                                session: session)
        
        // Then
        #expect(try response.statusCode == 200)
        #expect(capturedRequest?.httpMethod == "PATCH")
        #expect(String(data: capturedRequest?.httpBody ?? Data(), encoding: .utf8) == "key=value")
        
        let json: DataTest = try response.json()
        #expect(json.data == "key=value")
    }
    
    @Test func patchWithNoData() async throws {
        // Given
        let session = makeSession(body: Data(), statusCode: 200)
        
        // When
        let response = try await Requests.patch("http://localhost/patch",
                                                session: session)
        
        // Then
        #expect(try response.statusCode == 200)
    }
    
    @Test func patchWithJSONData() async throws {
        // Given
        var capturedRequest: URLRequest?
        let session = MockURLSession { request in
            capturedRequest = request
            return (Data("{\"data\":\"raw-body\"}".utf8), self.makeHTTPResponse(statusCode: 200))
        }
        
        // When
        let test = Test(value: "Test123")
        let response = try await Requests.patch("http://localhost/patch",
                                                json: test,
                                                session: session)
        
        // Then
        #expect(try response.statusCode == 200)
        #expect(capturedRequest?.httpBody == Data("{\"value\":\"Test123\"}".utf8))
        
        let json: DataTest = try response.json()
        #expect(json.data == "raw-body")
    }
    
    // MARK: - DELETE
    
    @Test func deleteWithData() async throws {
        // Given
        var capturedRequest: URLRequest?
        let session = MockURLSession { request in
            capturedRequest = request
            return (Data("{\"data\":\"key=value\"}".utf8), self.makeHTTPResponse(statusCode: 200))
        }
        
        // When
        let response = try await Requests.delete("http://localhost/delete",
                                                 data: ["key": "value"],
                                                 session: session)
        
        // Then
        #expect(try response.statusCode == 200)
        #expect(capturedRequest?.httpMethod == "DELETE")
        #expect(String(data: capturedRequest?.httpBody ?? Data(), encoding: .utf8) == "key=value")
        
        let json: DataTest = try response.json()
        #expect(json.data == "key=value")
    }
    
    @Test func deleteWithNoData() async throws {
        // Given
        let session = makeSession(body: Data(), statusCode: 200)
        
        // When
        let response = try await Requests.delete("http://localhost/delete",
                                                 session: session)
        
        // Then
        #expect(try response.statusCode == 200)
    }
    
    @Test func deleteWithJSONData() async throws {
        // Given
        var capturedRequest: URLRequest?
        let session = MockURLSession { request in
            capturedRequest = request
            return (Data("{\"data\":\"raw-body\"}".utf8), self.makeHTTPResponse(statusCode: 200))
        }
        
        // When
        let test = Test(value: "Test123")
        let response = try await Requests.delete("http://localhost/delete",
                                                 json: test,
                                                 session: session)
        
        // Then
        #expect(try response.statusCode == 200)
        #expect(capturedRequest?.httpBody == Data("{\"value\":\"Test123\"}".utf8))
        
        let json: DataTest = try response.json()
        #expect(json.data == "raw-body")
    }
   
    // MARK: - Response Error Tests
    
    @Test func statusCodeThrowsWhenNotHTTP() {
        // Given
        let url = URL(string: "file:///tmp/test.txt")!
        let response = Response(url: url.absoluteString,
                                data: nil,
                                response: URLResponse(url: url,
                                                      mimeType: nil,
                                                      expectedContentLength: 0,
                                                      textEncodingName: nil))
        
        // Then
        #expect(throws: ResponseError.invalidResponse) {
            _ = try response.statusCode
        }
    }
    
    @Test func jsonThrowsWhenNoData() {
        // Given
        let response = Response(url: "http://localhost",
                                data: nil,
                                response: nil)
        // Then
        #expect(throws: ResponseError.noData) {
            let _: DataTest = try response.json()
        }
    }
    
    @Test func jsonThrowsOnMalformedJSON() {
        // Given
        let response = Response(url: "http://localhost",
                                data: Data("invalid json".utf8),
                                response: nil)
        
        // Then
        #expect(throws: DecodingError.self) {
            let _: DataTest = try response.json()
        }
    }
    
    @Test func headersReturnsEmptyWhenResponseIsNil() async {
        // Given
        let response = Response(url: "http://localhost",
                                data: nil,
                                response: nil)
        
        // Then
        #expect(response.headers == [:])
    }
    
    // MARK: - Edge Case Tests
    
    @Test func dictionaryBodyDataWithEmptyDictionary() {
        // Given
        let dict: [String: String] = [:]
        let data = dict.bodyData()
        
        // Then
        #expect(data.isEmpty)
    }
    
    @Test func dictionaryBodyDataWithSpecialCharacters() {
        // Given
        let dict = ["key": "val&ue"]
        let data = dict.bodyData()
        
        // Then
        #expect(String(data: data, encoding: .utf8) == "key=val&ue")
    }
    
    // MARK: - invalidURL Test
    
    @Test func getWithInvalidURL() async throws {
        await #expect(throws: RequestError.invalidURL) {
            _ = try await Requests.get("", session: makeSession())
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
