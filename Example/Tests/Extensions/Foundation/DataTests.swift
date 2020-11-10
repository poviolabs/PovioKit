//
//  DataTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomažin on 10/11/2020.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import XCTest

class DatalTests: XCTestCase {
  func testHexadecialString() {
    let data = "this is a text string".data(using: .utf8)
    XCTAssertEqual(data?.hexadecialString, "746869732069732061207465787420737472696e67")
  }
}
