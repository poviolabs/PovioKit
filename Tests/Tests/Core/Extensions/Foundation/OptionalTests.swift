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
}
