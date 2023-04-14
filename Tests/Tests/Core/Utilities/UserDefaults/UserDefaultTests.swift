//
//  UserDefaultTests.swift
//  PovioKit
//
//  Created by Egzon Arifi on 25/01/2022.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitCore

class UserDefaultTests: XCTestCase {
  let userDefaults: UserDefaults = .standard
  
  override func tearDownWithError() throws {
    try super.tearDownWithError()
    userDefaults.removeObject(forKey: Defaults.testBoolKey)
    userDefaults.removeObject(forKey: Defaults.testStringKey)
    userDefaults.synchronize()
  }
  
  func testSaveStringValue() {
    // Given
    let givenValue = Defaults.testStringKey
    // When
    Defaults.screenName = givenValue
    // Then
    XCTAssertEqual(userDefaults.string(forKey: Defaults.testStringKey), Defaults.screenName)
  }
  
  func testSaveBoolValue() {
    // Given
    let givenValue = true
    // When
    Defaults.isAuthenticated = givenValue
    // Then
    XCTAssertEqual(userDefaults.bool(forKey: Defaults.testBoolKey), Defaults.isAuthenticated)
  }
}

extension UserDefaultTests {
  struct Defaults {
    static var testBoolKey = "test_bool_key"
    static var testStringKey = "test_string_key"
    
    @UserDefault(defaultValue: false, key: testBoolKey)
    static var isAuthenticated: Bool
    
    @UserDefault(defaultValue: "default", key: testStringKey)
    static var screenName: String
  }
}
