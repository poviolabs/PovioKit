//
//  XCTestCase+PovioKit.swift
//  PovioKit
//
//  Created by Gentian Barileva on 09/09/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import XCTest

public extension XCTestCase {
  func XCTAssertEqualURLRequest(_ lhs: URLRequest?, _ rhs: URLRequest?, file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertEqual(lhs, rhs, "Expected URLRequest to be equal", file: file, line: line)
    guard let lhs = lhs, let rhs = rhs else { return }
    XCTAssertEqual(lhs.url, rhs.url, "Expected url to be equal", file: file, line: line)
    XCTAssertEqual(lhs.httpMethod, rhs.httpMethod, "Expected httpMethod to be equal", file: file, line: line)
    XCTAssertEqual(lhs.httpBody ?? Data(), rhs.httpBody ?? Data(), "Expected httpBody to be equal", file: file, line: line)
    XCTAssertEqual(lhs.allHTTPHeaderFields ?? [:], rhs.allHTTPHeaderFields ?? [:], "Expected HTTPHeaderFields to be equal", file: file, line: line)
  }
}
