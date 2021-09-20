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
  
  func testAppending() {
    let url: URL = "https://github.com/poviolabs/PovioKit"
    let newUrl = url
      .appending("version", value: "0.4.0")
      .appending("build", value: "123&4$5-6")
      .appending("user", value: "John Doe")
      .appending("address", value: "Ljubljana+City")
    XCTAssertEqual(newUrl.absoluteString, "https://github.com/poviolabs/PovioKit?version=0.4.0&build=123%264$5-6&user=John%20Doe&address=Ljubljana%2BCity")
  }
}
