//
//  XCTestCase+PovioKit.swift
//  PovioKit
//
//  Created by Gentian Barileva on 09/09/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import XCTest

public extension XCTestCase {
  /**
   Use this method when you need to thoroughly assert URLRequest.
   
   Asserted properties:
   - `Self`
   - `url`
   - `httpMethod`
   - `httpBody`
   - `allHTTPHeaderFields`
   */
  func XCTAssertEqualURLRequest(_ lhs: URLRequest?, _ rhs: URLRequest?, file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertEqual(lhs, rhs, "Expected URLRequest to be equal", file: file, line: line)
    guard let lhs = lhs, let rhs = rhs else { return }
    XCTAssertEqual(lhs.url, rhs.url, "Expected url to be equal", file: file, line: line)
    XCTAssertEqual(lhs.httpMethod, rhs.httpMethod, "Expected httpMethod to be equal", file: file, line: line)
    XCTAssertEqual(lhs.httpBody ?? Data(), rhs.httpBody ?? Data(), "Expected httpBody to be equal", file: file, line: line)
    XCTAssertEqual(lhs.allHTTPHeaderFields ?? [:], rhs.allHTTPHeaderFields ?? [:], "Expected HTTPHeaderFields to be equal", file: file, line: line)
  }
  
  /**
   Use this method when you need to thoroughly assert URLRequest.
   
   Asserted properties:
   - `Self`
   - `url`
   - `httpMethod`
   - `httpBody`
   - `allHTTPHeaderFields`
   */
  func XCTAssertNotEqualURLRequest(_ lhs: URLRequest?, _ rhs: URLRequest?, file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertNotEqual(lhs, rhs, "Expected URLRequest not to be equal", file: file, line: line)
    guard let lhs = lhs, let rhs = rhs else { return }
    XCTAssertNotEqual(lhs.url, rhs.url, "Expected url not to be equal", file: file, line: line)
    XCTAssertNotEqual(lhs.httpMethod, rhs.httpMethod, "Expected httpMethod not to be equal", file: file, line: line)
    XCTAssertNotEqual(lhs.httpBody ?? Data(), rhs.httpBody ?? Data(), "Expected httpBody not to be equal", file: file, line: line)
    XCTAssertNotEqual(lhs.allHTTPHeaderFields ?? [:], rhs.allHTTPHeaderFields ?? [:], "Expected HTTPHeaderFields not to be equal", file: file, line: line)
  }
  
  func XCTAssertEqualImage(_ lhs: UIImage?, _ rhs: UIImage?, file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertNotNil(lhs, "Left image is nil", file: file, line: line)
    XCTAssertNotNil(rhs, "Right image is nil", file: file, line: line)
    guard let imageData1 = lhs?.pngData(),
          let imageData2 = rhs?.pngData() else { return }
    XCTAssertTrue(imageData1.elementsEqual(imageData2), "Images doesn't equal!", file: file, line: line)
  }
  
  func XCTAssertNotEqualImage(_ lhs: UIImage?, _ rhs: UIImage?, file: StaticString = #filePath, line: UInt = #line) {
    guard let imageData1 = lhs?.pngData(),
          let imageData2 = rhs?.pngData() else { return }
    XCTAssertFalse(imageData1.elementsEqual(imageData2), "Images do equal!", file: file, line: line)
  }
  
  func XCTAssertEqualFont(_ lhs: UIFont?, _ rhs: UIFont?, file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertEqual(lhs?.pointSize, rhs?.pointSize, "PointSize doesn't equal!", file: file, line: line)
    XCTAssertEqual(lhs?.fontName, rhs?.fontName, "FontName doesn't equal!", file: file, line: line)
    XCTAssertEqual(lhs?.familyName, rhs?.familyName, "FamilyName doesn't equal!", file: file, line: line)
  }
  
  func XCTAssertNotEqualFont(_ lhs: UIFont?, _ rhs: UIFont?, file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertNotNil(lhs, "Left font is nil", file: file, line: line)
    XCTAssertNotNil(rhs, "Right font is nil", file: file, line: line)
    let pointSizeEquals = lhs?.pointSize == rhs?.pointSize
    let fontNameEquals = lhs?.fontName == rhs?.fontName
    let familyNameEquals = lhs?.familyName == rhs?.familyName
    guard pointSizeEquals, fontNameEquals, familyNameEquals else { return }
    XCTFail("Fonts do equal!", file: file, line: line)
  }
}
