//
//  EncodableTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomažin on 11/11/2020.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import XCTest

class EncodableTests: XCTestCase {
  func testEncode() {
    let request = TestRequest(id: 1, name: "PovioKit")
    do {
      let json = try request.encode(with: JSONEncoder())
      XCTAssertEqual(json["id"] as? Int, 1)
      XCTAssertEqual(json["name"] as? String, "PovioKit")
    } catch {
      XCTFail("Could not encode TestRequest!")
    }
  }
}

private extension EncodableTests {
  struct TestRequest: Codable {
    let id: Int
    let name: String
  }
}
