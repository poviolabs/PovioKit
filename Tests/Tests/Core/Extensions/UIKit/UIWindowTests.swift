//
//  UIWindowTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomazin on 6/1/2022.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import XCTest
import UIKit
import PovioKitCore

class UIWindowTests: XCTestCase {
  func test_safeAreaInsets() {
    let window = UIWindow()
    window.makeKeyAndVisible()
    // this values work for iPhone 14 flavors
    XCTAssertEqual(window.safeAreaInsets.top, 59)
    XCTAssertEqual(window.safeAreaInsets.left, 0)
    XCTAssertEqual(window.safeAreaInsets.right, 0)
    XCTAssertEqual(window.safeAreaInsets.bottom, 34)
  }
}
