//
//  UIEdgeInsetsTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomažin on 23/12/2019.
//  Copyright © 2021 Povio Inc. All rights reserved.
//

import XCTest
import PovioKit

class UIEdgeInsetsTests: XCTestCase {
  func testAll() {
    let allInsets = UIEdgeInsets(all: 10)
    XCTAssertEqual(allInsets.top, 10)
    XCTAssertEqual(allInsets.bottom, 10)
    XCTAssertEqual(allInsets.left, 10)
    XCTAssertEqual(allInsets.right, 10)
  }
  
  func testVertical() {
    let verticalInsets = UIEdgeInsets(vertical: 10)
    XCTAssertEqual(verticalInsets.top, 10)
    XCTAssertEqual(verticalInsets.bottom, 10)
    XCTAssertEqual(verticalInsets.left, 0)
    XCTAssertEqual(verticalInsets.right, 0)
  }
  
  func testHorizontal() {
    let verticalInsets = UIEdgeInsets(horizontal: 10)
    XCTAssertEqual(verticalInsets.top, 0)
    XCTAssertEqual(verticalInsets.bottom, 0)
    XCTAssertEqual(verticalInsets.left, 10)
    XCTAssertEqual(verticalInsets.right, 10)
  }
  
  func testVerticalCombined() {
    let verticalInsets = UIEdgeInsets(vertical: 10)
    XCTAssertEqual(verticalInsets.vertical, 20)
  }
  
  func testHorizontalCombined() {
    let horizontalInsets = UIEdgeInsets(horizontal: 10)
    XCTAssertEqual(horizontalInsets.horizontal, 20)
  }
}
