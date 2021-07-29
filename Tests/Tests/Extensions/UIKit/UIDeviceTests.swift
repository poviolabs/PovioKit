//
//  UIDeviceTests.swift
//  PovioKit_Tests
//
//  Created by Klemen Zagar on 05/12/2019.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import XCTest
@testable import PovioKit

class UIDeviceTests: XCTestCase {
  func testAppVariablesNotEmpty() {
    let sut = UIDevice.current
    XCTAssertFalse(sut.osVersion.isEmpty, "OS version should not be empty")
    XCTAssertFalse(sut.deviceName.isEmpty, "Device name should not be empty")
    XCTAssertFalse(sut.deviceCodeName.isEmpty, "Device code name should not be empty")
  }
}
