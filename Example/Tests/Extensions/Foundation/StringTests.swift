//
//  StringTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomažin on 05/05/2019.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import XCTest
import PovioKit

class StringTests: XCTestCase {
  func testLocalized() {
    XCTAssertEqual("this-doesn't exist".localized(), "this-doesn't exist")
  }
  
  func testTrimed() {
    XCTAssertEqual("  test".trimed, "test")
    XCTAssertEqual("test  ".trimed, "test")
    XCTAssertEqual("  test  ".trimed, "test")
    XCTAssertEqual("\n\n   test  \n\n".trimed, "test")
  }
  
  func testDigits() {
    XCTAssertEqual("abc123".digits, "123")
    XCTAssertEqual("123abc".digits, "123")
    XCTAssertEqual("abc123def".digits, "123")
    XCTAssertEqual("abc".digits, "")
    XCTAssertEqual("abc123?!*+-=".digits, "123")
  }
  
  func testBase64() {
    let string = "What a nice day we have :)"
    XCTAssertEqual(string.base64, "V2hhdCBhIG5pY2UgZGF5IHdlIGhhdmUgOik=")
  }
  
  func testIsEmail() {
    XCTAssertTrue("valid@email.com".isEmail)
    XCTAssertTrue("try.this+1@email.com".isEmail)
    XCTAssertFalse("invalid.email.com".isEmail)
    XCTAssertFalse("invalid@".isEmail)
    XCTAssertFalse("invalid@email".isEmail)
    XCTAssertFalse("@email.com".isEmail)
    XCTAssertFalse("invalid@@email.com".isEmail)
  }
  
  func testFirstNCharacters() {
    let string = "Today is a great day!"
    XCTAssertEqual(string.first(n: 5), "Today")
  }
  
  func testLastNCharacters() {
    let string = "Today is a great day!"
    XCTAssertEqual(string.last(n: 4), "day!")
  }
}
