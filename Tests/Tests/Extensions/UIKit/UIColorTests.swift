//
//  UIColorTests.swift
//  PovioKit_Tests
//
//  Created by Klemen Zagar on 05/12/2019.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import XCTest
@testable import PovioKit

class UIColorTests: XCTestCase {
  func testIfRed() {
    let color = UIColor(red: 255, green: 0, blue: 0)
    XCTAssert(color.isEqual(UIColor.red), "Created color should be red")
  }
  
  func testIfRedWithAlpha() {
    let alpha: CGFloat = 0.5
    let color = UIColor(red: 255, green: 0, blue: 0, alpha: alpha)
    XCTAssert(color.isEqual(UIColor.red.withAlphaComponent(alpha)), "Created color should be red with alpha: \(alpha)")
  }
}
