//
//  CollectionTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomažin on 05/05/2019.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitCore

class CollectionTests: XCTestCase {
  func testSafeSubscript() {
    let array = [1, 2]
    XCTAssertEqual(array[safe: 0], 1)
    XCTAssertEqual(array[safe: 1], 2)
    XCTAssertNil(array[safe: 2])
  }
  
  func testConditionalCount() {
    let array: [Any] = ["one", "two", 3, 4]
    XCTAssertEqual(array.count(where: { $0 is String}), 2)
    XCTAssertEqual(array.count(where: { $0 is Int}), 2)
  }
}
