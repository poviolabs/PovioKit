//
//  UICollectionReusableViewTests.swift
//  PovioKit_Tests
//
//  Created by Ndriqim Nagavci on 25/10/2022.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitCore

class UICollectionReusableViewTests: XCTestCase {
  func test_identifier_returnsCorrectIdentifier() {
    let SUTs: [(expectedIdentifier: String, cell: UICollectionReusableView.Type)] = [("IdentifierTest", IdentifierTest.self), ("SomeCustomCell", SomeCustomCell.self)]
    
    for sut in SUTs {
      XCTAssertEqual(sut.expectedIdentifier, sut.cell.identifier)
    }
  }
}

private class IdentifierTest: UICollectionReusableView { }
private class SomeCustomCell: UICollectionReusableView { }
