//
//  DoubleTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomažin on 11/11/2020.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import XCTest

class DoubleTests: XCTestCase {
  func testMilesToMeters() {
    XCTAssertEqual(10.0.meters.rounded(), 16093)
  }
  
  func testMetersToMiles() {
    XCTAssertEqual(16000.miles.rounded(), 10)
  }
}
