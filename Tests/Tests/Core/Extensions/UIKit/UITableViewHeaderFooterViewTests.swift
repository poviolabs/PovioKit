//
//  UITableViewHeaderFooterViewTests.swift
//  PovioKit_Tests
//
//  Created by Gentian Barileva on 02/06/2022.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import XCTest
import PovioKit

class UITableViewHeaderFooterViewTests: XCTestCase {
  func test_identifier_returnsCorrectIdentifier() {
    let SUTs: [(expectedIdentifier: String, mkAnnotationView: UITableViewHeaderFooterView.Type)] = [("CustomUITableViewHeaderFooterView", CustomUITableViewHeaderFooterView.self), ("OtherUITableViewHeaderFooterView", OtherUITableViewHeaderFooterView.self)]
    
    for sut in SUTs {
      XCTAssertEqual(sut.expectedIdentifier, sut.mkAnnotationView.identifier)
    }
  }
}

// MARK: - Helpers
private class CustomUITableViewHeaderFooterView: UITableViewHeaderFooterView { }
private class OtherUITableViewHeaderFooterView: UITableViewHeaderFooterView { }
