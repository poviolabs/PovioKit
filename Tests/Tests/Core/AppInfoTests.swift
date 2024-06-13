//
//  AppInfoTests.swift
//  PovioKit_Tests
//
//  Created by Toni Kocjan on 19/02/2021.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

#if os(iOS)
import XCTest
import PovioKitCore

class AppInfoTests: XCTestCase {
  func testAppVariablesNotEmpty() {
    XCTAssertFalse(AppInfo.name.isEmpty, "App name should not be empty")
    XCTAssertFalse(AppInfo.version.isEmpty, "App version should not be empty")
    XCTAssertFalse(AppInfo.build.isEmpty, "App build number should not be empty")
    XCTAssertFalse(AppInfo.bundleId.isEmpty, "App bundleId should not be empty")
  }
}
#endif
