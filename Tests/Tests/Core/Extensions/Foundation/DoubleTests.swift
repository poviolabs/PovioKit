//
//  DoubleTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomažin on 02/09/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import XCTest
import PovioKit

class DoubleTests: XCTestCase {
  func testDegreesToRadians() {
    XCTAssertEqual(90.radians, 90 * .pi / 180)
    XCTAssertEqual(90.radians, 1.5707963267948966)
  }
  
  func testRadiansToDegress() {
    XCTAssertEqual(1.5.degrees, 1.5 * 180 / .pi)
    XCTAssertEqual(1.5.degrees, 85.94366926962348)
  }
}
