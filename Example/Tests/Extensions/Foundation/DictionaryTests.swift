//
//  DictionaryTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomažin on 11/11/2020.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import XCTest

class DictionaryTests: XCTestCase {
  func testUnion() {
    let dict1 = [0: "Apple", 1: "Orange"]
    let dict2 = [2: "Pinaple"]
    let union = dict1.union(dict2)
    XCTAssertEqual(union.count, 3)
    XCTAssertEqual(union[0], "Apple")
    XCTAssertEqual(union[1], "Orange")
    XCTAssertEqual(union[2], "Pinaple")
  }
}
