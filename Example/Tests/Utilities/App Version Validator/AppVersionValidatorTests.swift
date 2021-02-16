//
//  AppVersionValidatorTests.swift
//  PovioKit_Tests
//
//  Created by Toni Kocjan on 16/02/2021.
//  Copyright © 2021 Povio Labs. All rights reserved.
//

import XCTest
@testable import PovioKit

class AppVersionValidatorTests: XCTestCase {
  func testValidator() {
    let validator = AppVersionValidator()
    XCTAssert(validator.isAppVersion("1.8.4", equalOrHigherThan: "1.8.4"))
    XCTAssert(validator.isAppVersion("1.8.5", equalOrHigherThan: "1.8.4"))
    XCTAssert(validator.isAppVersion("1.9.4", equalOrHigherThan: "1.8.4"))
    XCTAssert(validator.isAppVersion("2.0.0", equalOrHigherThan: "1.8.4"))
    XCTAssert(validator.isAppVersion("1.9.0", equalOrHigherThan: "1.8.4"))
    XCTAssert(validator.isAppVersion("2.0.0", equalOrHigherThan: "2"))
    XCTAssert(validator.isAppVersion("2.0.1", equalOrHigherThan: "2"))
    XCTAssert(validator.isAppVersion("2.2.2", equalOrHigherThan: "2"))
    XCTAssert(validator.isAppVersion("2.2", equalOrHigherThan: "2"))
    XCTAssert(validator.isAppVersion("2", equalOrHigherThan: "2"))
    XCTAssert(validator.isAppVersion("3", equalOrHigherThan: "2.0.0.8"))
    XCTAssert(validator.isAppVersion("1", equalOrHigherThan: ""))
    XCTAssertFalse(validator.isAppVersion("1.8.3", equalOrHigherThan: "1.8.4"))
    XCTAssertFalse(validator.isAppVersion("1.7.9", equalOrHigherThan: "1.8.4"))
    XCTAssertFalse(validator.isAppVersion("0.8.8", equalOrHigherThan: "1.8.4"))
    XCTAssertFalse(validator.isAppVersion("1.9.9", equalOrHigherThan: "2"))
    XCTAssertFalse(validator.isAppVersion("1.9", equalOrHigherThan: "2"))
    XCTAssertFalse(validator.isAppVersion("1", equalOrHigherThan: "2"))
    XCTAssertFalse(validator.isAppVersion("2", equalOrHigherThan: "2.0.0.8"))
    XCTAssertFalse(validator.isAppVersion("2", equalOrHigherThan: "2.0.0.1"))
  }
}
