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
    let url = URL(string: "https://www.povio.com")!
    let data1 = "TestData".data(using: .utf8)
    let data2 = "Povio🚀".data(using: .utf8)
    
    var firstUrlRequest = URLRequest(url: url)
    firstUrlRequest.httpBody = data1
    
    var secondUrlRequest = URLRequest(url: url)
    secondUrlRequest.httpBody = data2
    
    // Test passes even though httpBody is different.
    XCTAssertEqual(firstUrlRequest, secondUrlRequest)
    
    XCTExpectFailure("Expected test to fail since httpBody is different.") {
      XCTAssertEqual(firstUrlRequest.httpBody, secondUrlRequest.httpBody)
      XCTAssertEqualURLRequest(firstUrlRequest, secondUrlRequest)
    }
  }
}
