//
//  DataTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomažin on 10/11/2020.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import XCTest

class DataTests: XCTestCase {
  func testHexadecialString() {
    let data = "this is a text string".data(using: .utf8)
    XCTAssertEqual(data?.hexadecialString, "746869732069732061207465787420737472696e67")
  }
  
  func testDecode() {
    let responseString = """
    {"id": 1, "name": "PovioKit"}
    """
    let data = responseString.data(using: .utf8)
    
    do {
      let object = try data?.decode(TestResponse.self, with: JSONDecoder())
      XCTAssertEqual(object?.id, 1)
      XCTAssertEqual(object?.name, "PovioKit")
    } catch {
      XCTFail("Could not decode TestResponse!")
    }
  }
}

private extension DataTests {
  struct TestResponse: Decodable {
    let id: Int
    let name: String
  }
}
