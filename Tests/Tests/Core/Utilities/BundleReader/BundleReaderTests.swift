//
//  BundleReaderTests.swift
//  PovioKit_Tests
//
//  Created by Gentian Barileva on 01/06/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import XCTest
import PovioKit

class BundleReaderTests: XCTestCase {
  func test_init_doesNotMessageTheReader() {
    let reader = BundleSpy()
    let _ = BundleReader(bundle: reader)
    
    XCTAssertNil(reader.capturedRead)
  }
}

// MARK: - Helpers
private class BundleSpy: Bundle {
  private(set) var capturedRead: String?
  
  override func object(forInfoDictionaryKey key: String) -> Any? {
    capturedRead = key
    
    return nil
  }
}
