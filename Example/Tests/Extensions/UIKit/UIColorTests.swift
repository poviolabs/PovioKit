//
//  UIColorTests.swift
//  PovioKit_Tests
//
//  Created by Klemen Zagar on 05/12/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import PovioKit

class UIColorTests: XCTestCase {

  func testIfBlack() {
    let color = UIColor(red: 0, green: 0, blue: 0)
    XCTAssert(color.isEqual(UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)), "Created color should be black")
  }
  
  func testIfWhite() {
    let color = UIColor(red: 255, green: 255, blue: 255)
    print(color)
    print(UIColor(red: 1, green: 1, blue: 1))
    XCTAssert(color.isEqual(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)), "Created color should be white")
  }
  
  func testIfRed() {
    let color = UIColor(red: 255, green: 0, blue: 0)
    XCTAssert(color.isEqual(UIColor.red), "Created color should be red")
  }
  
  func testIfGreen() {
    let color = UIColor(red: 0, green: 255, blue: 0)
    XCTAssert(color.isEqual(UIColor.green), "Created color should be green")
  }
  
  func testIfBlue() {
    let color = UIColor(red: 0, green: 0, blue: 255)
    XCTAssert(color.isEqual(UIColor.blue), "Created color should be blue")
  }
}
