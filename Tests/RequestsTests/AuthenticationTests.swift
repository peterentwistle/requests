//
//  AuthenticationTests.swift
//  RequestsTests
//
//  Copyright 2026 Peter Entwistle
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

@Suite struct AuthenticationTests {

    // MARK: - Bearer Authentication

    @Test func bearerAuthenticationReturnsCorrectAuthorizationHeader() {
        // Given
        let bearerAuthentication = BearerAuthentication(token: "1234")

        // When
        let authHeader = bearerAuthentication.authorizationHeader

        // Then
        #expect(authHeader == "Bearer 1234")
    }

    @Test func bearerAuthenticationSanitizesLineBreaksInToken() {
        // Given
        let bearerAuthentication = BearerAuthentication(token: "abc123\r\ndef456")

        // When
        let authHeader = bearerAuthentication.authorizationHeader

        // Then
        #expect(authHeader == "Bearer abc123def456")
    }

    @Test func bearerAuthenticationSanitizesCarriageReturnInToken() {
        // Given
        let bearerAuthentication = BearerAuthentication(token: "abc123\rdef456")

        // When
        let authHeader = bearerAuthentication.authorizationHeader

        // Then
        #expect(authHeader == "Bearer abc123def456")
    }

    @Test func bearerAuthenticationSanitizesLineFeedInToken() {
        // Given
        let bearerAuthentication = BearerAuthentication(token: "abc123\ndef456")

        // When
        let authHeader = bearerAuthentication.authorizationHeader

        // Then
        #expect(authHeader == "Bearer abc123def456")
    }
}
