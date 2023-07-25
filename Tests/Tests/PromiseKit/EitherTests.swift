//
//  EitherTests.swift
//  PovioKit_Tests
//
//  Created by Toni Kocjan on 31/01/2020.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitPromise

class EitherTests: XCTestCase {
  func testIsLeftOrRight() {
    XCTAssertEqual(Either<Int, Bool>.left(10).isLeft, true)
    XCTAssertEqual(Either<Int, Bool>.left(10).isRight, false)
    XCTAssertEqual(Either<Int, Bool>.right(true).isLeft, false)
    XCTAssertEqual(Either<Int, Bool>.right(true).isRight, true)
    XCTAssertEqual(Either<Int, Bool>.left(10).left, 10)
    XCTAssertEqual(Either<Int, Bool>.left(10).right, nil)
    XCTAssertEqual(Either<Int, Bool>.right(true).left, nil)
    XCTAssertEqual(Either<Int, Bool>.right(true).right, true)
  }
  
  func testMap() {
    XCTAssertEqual(Either<Int, Bool>.left(10).mapLeft(String.init), .left("10"))
    XCTAssertEqual(Either<Int, Bool>.left(10).mapRight(String.init), .left(10))
    XCTAssertEqual(Either<Int, Bool>.right(true).mapLeft(String.init), .right(true))
    XCTAssertEqual(Either<Int, Bool>.right(true).mapRight(String.init), .right("true"))
  }
  
  func testFlatMap() {
    XCTAssertEqual(Either<Int, Bool>.left(10).flatMapLeft { .left(Double($0)) }, .left(10.0))
    XCTAssertEqual(Either<Int, Bool>.left(10).flatMapRight { .right($0) }, .left(10))
    XCTAssertEqual(Either<Int, Bool>.right(true).flatMapLeft { .left($0) }, .right(true))
    XCTAssertEqual(Either<Int, Bool>.right(true).flatMapRight { .right(String($0)) }, .right("true"))
  }
}
