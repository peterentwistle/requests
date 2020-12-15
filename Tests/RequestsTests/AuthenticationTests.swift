//
//  AuthenticationTests.swift
//  RequestsTests
//
//  Created by Peter Entwistle on 08/12/2020.
//

import XCTest
import Requests

class AuthenticationTests: XCTestCase {

    func testWhenBearerAuthenticationObjectIsCreatedWithATokenValue_ThenTheCorrectAuthorizationHeaderIsReturned() {
        // Given
        let bearerAuthentication = BearerAuthentication(token: "1234")
        
        // When
        let authHeader = bearerAuthentication.authorizationHeader
        
        // Then
        XCTAssertEqual("Bearer 1234", authHeader)
    }
}
