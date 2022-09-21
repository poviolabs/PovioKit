//
//  DictionaryTests.swift
//  
//
//  Created by Borut Tomazin on 21/09/2022.
//

import XCTest

final class DictionaryTests: XCTestCase {
  func testUnionWithoutIntersection() {
    let sut1 = [1: "One", 2: "Two", 3: "Three"]
    let sut2 = [4: "Four", 5: "Five"]
    
    let result = sut1.union(sut2)
    XCTAssertEqual(result.count, 5)
    XCTAssertEqual(result[1], "One")
    XCTAssertEqual(result[2], "Two")
    XCTAssertEqual(result[3], "Three")
    XCTAssertEqual(result[4], "Four")
    XCTAssertEqual(result[5], "Five")
  }
  
  func testUnionWithIntersection() {
    let sut1 = [1: "One", 2: "Two", 3: "Three"]
    let sut2 = [3: "Three", 4: "Four"]
    
    let result = sut1.union(sut2)
    XCTAssertEqual(result.count, 4)
    XCTAssertEqual(result[1], "One")
    XCTAssertEqual(result[2], "Two")
    XCTAssertEqual(result[3], "Three")
    XCTAssertEqual(result[4], "Four")
  }
}
