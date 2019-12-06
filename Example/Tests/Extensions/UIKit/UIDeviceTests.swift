//
//  UIDeviceTests.swift
//  PovioKit_Tests
//
//  Created by Klemen Zagar on 05/12/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import PovioKit

class UIDeviceTests: XCTestCase {
  
    func testAppVariablesNotEmpty() {
      let sut = UIDevice.current
      XCTAssert(!sut.osVersion.isEmpty, "OS version should not be empty")
      XCTAssert(!sut.deviceName.isEmpty, "Device name should not be empty")
      XCTAssert(!sut.deviceCodeName.isEmpty, "Device code name should not be empty")
      XCTAssert(!sut.appName.isEmpty, "App name should not be empty")
      XCTAssert(!sut.appVersion.isEmpty, "App version should not be empty")
      XCTAssert(!sut.appBuild.isEmpty, "App build number should not be empty")
    }
  
}
