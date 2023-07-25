//
//  UIApplicationTests.swift
//  PovioKit_Tests
//
//  Created by Toni Kocjan on 19/02/2021.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import XCTest

class UIApplicationTests: XCTestCase {
  func testAppVariablesNotEmpty() {
    let app = UIApplication.shared
    XCTAssertFalse(app.name.isEmpty, "App name should not be empty")
    XCTAssertFalse(app.version.isEmpty, "App version should not be empty")
    XCTAssertFalse(app.build.isEmpty, "App build number should not be empty")
  }
}
