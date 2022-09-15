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
  
  func test_XCTAssertNotEqualURLRequest_passesOnDifferentURLRequest() {
    let data1 = "TestData".data(using: .utf8)
    let data2 = "Povio👨‍💻".data(using: .utf8)
    
    var firstUrlRequest = anyRequest()
    firstUrlRequest.httpBody = data1
    firstUrlRequest.httpMethod = "POST"
    firstUrlRequest.setValue("", forHTTPHeaderField: "")
    
    var secondUrlRequest = anyRequest(urlString: "https://www.pov.io")
    secondUrlRequest.httpBody = data2
    firstUrlRequest.httpMethod = "PUT"
    
    XCTAssertNotEqualURLRequest(firstUrlRequest, secondUrlRequest)
    XCTAssertNotEqual(firstUrlRequest, secondUrlRequest)
    XCTAssertNotEqual(firstUrlRequest.url, secondUrlRequest.url)
    XCTAssertNotEqual(firstUrlRequest.httpMethod, secondUrlRequest.httpMethod)
    XCTAssertNotEqual(firstUrlRequest.httpBody ?? Data(), secondUrlRequest.httpBody ?? Data())
    XCTAssertNotEqual(firstUrlRequest.allHTTPHeaderFields ?? [:], secondUrlRequest.allHTTPHeaderFields ?? [:])
  }
  
  func test_XCTAssertNotEqualURLRequest_passesOnDifferentURLRequestCombinations() {
    let firstUrlRequest = anyRequest()
    
    var secondUrlRequest = anyRequest(urlString: "https://www.pov.io")
    secondUrlRequest.httpBody = "Povio👨‍💻".data(using: .utf8)
    secondUrlRequest.httpMethod = "PUT"
    secondUrlRequest.setValue("", forHTTPHeaderField: "")

    let possibleCombinations: [(URLRequest?, URLRequest?)] = [(firstUrlRequest, nil),
                                                               (nil, secondUrlRequest),
                                                               (firstUrlRequest, secondUrlRequest)]
    
    possibleCombinations.forEach { combination in
      XCTAssertNotEqualURLRequest(combination.0, combination.1)
    }
    XCTExpectFailure("Expected nil URLRequest to not be equal") {
      XCTAssertNotEqualURLRequest(nil, nil)
    }
  }
  
  func test_image_isEqual() {
    XCTAssertEqualImage(UIImage(systemName: "sun.min"), UIImage(systemName: "sun.min"))
    XCTAssertEqualImage(UIImage(), UIImage())
    
    XCTExpectFailure("Failed", options: .nonStrict()) {
      XCTAssertEqualImage(UIImage(), nil)
      XCTAssertEqualImage(nil, UIImage())
      XCTAssertEqualImage(nil, nil)
    }
  }
  
  func test_image_isNotEqual() {
    XCTAssertNotEqualImage(UIImage(systemName: "sun.min"), UIImage(systemName: "sun.max"))
    XCTAssertNotEqualImage(UIImage(), nil)
    
    XCTExpectFailure {
      XCTAssertNotEqualImage(UIImage(systemName: "sun.min"), UIImage(systemName: "sun.min"))  
    }
  }
  
  func test_font_isEqual() {
    XCTAssertEqualFont(lhs: UIFont.systemFont(ofSize: 12), rhs: UIFont.systemFont(ofSize: 12))
  }
  
  func test_font_isNotEqual() {
    XCTAssertNotEqualFont(lhs: UIFont.systemFont(ofSize: 12), rhs: UIFont.systemFont(ofSize: 13))
    XCTAssertNotEqualFont(lhs: UIFont.systemFont(ofSize: 12), rhs: UIFont.boldSystemFont(ofSize: 12))
    XCTAssertNotEqualFont(lhs: UIFont.systemFont(ofSize: 12), rhs: UIFont.italicSystemFont(ofSize: 12))
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
