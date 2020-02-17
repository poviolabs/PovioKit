//
//  URLTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomažin on 05/05/2019.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import XCTest
import PovioKit

class URLTests: XCTestCase {
  func testInitWithString() {
    let urlString = "https://github.com/poviolabs/PovioKit"
    XCTAssertEqual(URL(string: urlString)?.absoluteString, urlString)
    XCTAssertNil(URL(string: "")?.absoluteString)
  }
  
  func testInitWithStringLiteral() {
    let url: URL = "https://github.com/poviolabs/PovioKit"
    XCTAssertNotNil(url)
  }
}
