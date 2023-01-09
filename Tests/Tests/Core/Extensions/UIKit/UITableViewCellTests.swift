//
//  UITableViewCellTests.swift
//  PovioKit_Tests
//
//  Created by Gentian Barileva on 01/06/2022.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import XCTest
import PovioKit

class TableViewCellIdentifierTests: XCTestCase {
  func test_identifier_returnsCorrectIdentifier() {    
    let SUTs: [(expectedIdentifier: String, cell: UITableViewCell.Type)] = [("IdentifierTest", IdentifierTest.self), ("SomeCustomCell", SomeCustomCell.self)]
    
    for sut in SUTs {
      XCTAssertEqual(sut.expectedIdentifier, sut.cell.identifier)
    }
  }
}

private class IdentifierTest: UITableViewCell { }
private class SomeCustomCell: UITableViewCell { }
