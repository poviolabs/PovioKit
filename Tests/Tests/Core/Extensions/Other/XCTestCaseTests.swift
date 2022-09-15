//
//  XCTestCaseTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomazin on 15/09/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import XCTest

final class XCTestCaseTests: XCTestCase {
  func test_XCTAssertEqualURLRequest_httpBodyFailsOnDifferentDataSets() {
    let data1 = "TestData".data(using: .utf8)
    let data2 = "Povio🚀".data(using: .utf8)
    
    var firstUrlRequest = anyRequest()
    firstUrlRequest.httpBody = data1
    
    var secondUrlRequest = anyRequest()
    secondUrlRequest.httpBody = data2
    
    // Test passes even though httpBody is different.
    XCTAssertEqual(firstUrlRequest, secondUrlRequest)
    
    XCTExpectFailure("Expected test to fail since httpBody is different.") {
      XCTAssertEqual(firstUrlRequest.httpBody, secondUrlRequest.httpBody)
      XCTAssertEqualURLRequest(firstUrlRequest, secondUrlRequest)
    }
  }
  
  func test_XCTAssertEqualURLRequest_hasExpectedFailures() {
    let firstUrlRequest = anyRequest()
    let secondUrlRequest = anyRequest(urlString: "https://www.pov.io")


    let possibleCombinations: [(URLRequest?, URLRequest?)] = [(firstUrlRequest, nil),
                                                               (nil, secondUrlRequest),
                                                               (firstUrlRequest, secondUrlRequest)]
    
    possibleCombinations.forEach { combination in
      expectFailures(combination.0, combination.1, message: "Expected test to fail \(combination)")
    }
  }
  
  func test_XCTAssertEqualURLRequest_failsOnDifferentHttpMethods() {
    var getRequest = anyRequest()
    getRequest.httpMethod = "GET"
    
    var postRequest = anyRequest()
    postRequest.httpMethod = "POST"
    
    expectFailures(getRequest, postRequest, message: "Expected test to fail since httpMethod is different.")
  }
  
  func test_XCTAssertEqualURLRequest_failsOnDifferentHttpHeaderFields() {
    var getRequest = anyRequest()
    getRequest.setValue("", forHTTPHeaderField: "")
    
    let postRequest = anyRequest()
    
    expectFailures(getRequest, postRequest, message: "Expected test to fail since httpHeaderField is different.")
  }
}

// MARK: - Helpers
private extension XCTestCaseTests {
  func anyRequest(urlString: String = "https://www.povio.com") -> URLRequest {
    let url = URL(string: urlString)!
    return URLRequest(url: url)
  }
  
  func expectFailures(_ lhs: URLRequest?, _ rhs: URLRequest?, message: String, file: StaticString = #filePath, line: UInt = #line) {
    XCTExpectFailure(message) {
      XCTAssertEqual(lhs, rhs, file: file, line: line)
      XCTAssertEqualURLRequest(lhs, rhs, file: file, line: line)
    }
  }
}
