//
//  DispatchTimeIntervalTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomažin on 11/11/2020.
//  Copyright © 2021 Povio Inc. All rights reserved.
//

import XCTest

class DispatchTimeIntervalTests: XCTestCase {
  func testTimeInterval() {
    let dispatchInterval: DispatchTimeInterval = .seconds(5)
    let timeInterval = dispatchInterval.timeInterval
    XCTAssertEqual(timeInterval, 5)
  }
}
