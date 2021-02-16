//
//  AppVersionValidator.swift
//  Alamofire
//
//  Created by Toni Kocjan on 16/02/2021.
//

import Foundation

final public class AppVersionValidator {
  /// Validate given app version with minimum required version:
  ///
  /// Examples:
  ///  XCTAssert(validator.isAppVersion("1.8.4", equalOrHigherThan: "1.8.4"))
  ///  XCTAssert(validator.isAppVersion("1.8.5", equalOrHigherThan: "1.8.4"))
  ///  XCTAssert(validator.isAppVersion("1.9.4", equalOrHigherThan: "1.8.4"))
  ///  XCTAssert(validator.isAppVersion("2.0.0", equalOrHigherThan: "1.8.4"))
  ///  XCTAssert(validator.isAppVersion("1.9.0", equalOrHigherThan: "1.8.4"))
  ///  XCTAssert(validator.isAppVersion("2.0.0", equalOrHigherThan: "2"))
  ///  XCTAssert(validator.isAppVersion("2.0.1", equalOrHigherThan: "2"))
  ///  XCTAssert(validator.isAppVersion("2.2.2", equalOrHigherThan: "2"))
  ///  XCTAssert(validator.isAppVersion("2.2", equalOrHigherThan: "2"))
  ///  XCTAssert(validator.isAppVersion("2", equalOrHigherThan: "2"))
  ///  XCTAssert(validator.isAppVersion("3", equalOrHigherThan: "2.0.0.8"))
  ///  XCTAssert(validator.isAppVersion("1", equalOrHigherThan: ""))
  ///  XCTAssertFalse(validator.isAppVersion("1.8.3", equalOrHigherThan: "1.8.4"))
  ///  XCTAssertFalse(validator.isAppVersion("1.7.9", equalOrHigherThan: "1.8.4"))
  ///  XCTAssertFalse(validator.isAppVersion("0.8.8", equalOrHigherThan: "1.8.4"))
  ///  XCTAssertFalse(validator.isAppVersion("1.9.9", equalOrHigherThan: "2"))
  ///  XCTAssertFalse(validator.isAppVersion("1.9", equalOrHigherThan: "2"))
  ///  XCTAssertFalse(validator.isAppVersion("1", equalOrHigherThan: "2"))
  ///  XCTAssertFalse(validator.isAppVersion("2", equalOrHigherThan: "2.0.0.8"))
  ///  XCTAssertFalse(validator.isAppVersion("2", equalOrHigherThan: "2.0.0.1"))
  ///
  public func isAppVersion(
    _ version: String,
    equalOrHigherThan minimalRequiredVersion: String
  ) -> Bool {
    let appVersionComponents = version
      .components(separatedBy: ".").lazy
      .compactMap(Int.init)
    let requiredVersionComponents = minimalRequiredVersion
      .components(separatedBy: ".").lazy
      .compactMap(Int.init)
    for (required, app) in zip(requiredVersionComponents, appVersionComponents) {
      if app > required { return true }
      if app < required { return false }
    }
    return appVersionComponents.count >= requiredVersionComponents.count
  }
}
