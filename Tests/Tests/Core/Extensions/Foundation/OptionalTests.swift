//
//  OptionalTests.swift
//  PovioKit_Tests
//
//  Created by Klemen Zagar on 05/12/2019.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import XCTest

class OptionalTests: XCTestCase {
  func testArrayNilOrEmptyTrueWhenNil() {
    let sut: [String]? = nil
    XCTAssertTrue(sut.isNilOrEmpty, "Should not return false when collection is nil")
  }
  
  func testArrayNilOrEmptyTrueWhenEmpty() {
    let sut: [String]? = []
    XCTAssertTrue(sut.isNilOrEmpty, "Should not return false when collection is empty")
  }
  
  func testArrayNilOrEmptyFalseWhenNonEmpty() {
    let sut: [String]? = ["A"]
    XCTAssertFalse(sut.isNilOrEmpty, "Should not return true when collection is populated")
  }
  
  func testStringNilOrEmptyTrueWhenNil() {
    let sut: String? = nil
    XCTAssertTrue(sut.isNilOrEmpty, "Should not return false when string is nil")
  }
  
  func testStringNilOrEmptyTrueWhenEmpty() {
    let sut: String? = ""
    XCTAssertTrue(sut.isNilOrEmpty, "Should not return false when string is empty")
  }
  
  func testStringNilOrEmptyFalseWhenNonEmpty() {
    let sut: String? = "A"
    XCTAssertFalse(sut.isNilOrEmpty, "Should not return true when string contains characters")
  }
  
  func test_replacingString_producesExpectedResult() {
    let sut: String? = "Nice day today!"
    XCTAssertEqual(sut.replacingString(with: "night", range: NSRange(location: 5, length: 3)), "Nice night today!")
  }
  
  func test_replacingString_doesNothingOnNilValue() {
    let sut: String? = nil
    XCTAssertNotEqual(sut.replacingString(with: "night", range: NSRange(location: 0, length: 0)), "Nice night today!")
  }
}
