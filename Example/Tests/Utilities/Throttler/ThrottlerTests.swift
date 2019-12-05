//
//  ThrottlerTests.swift
//  PovioKit_Tests
//
//  Created by Klemen Zagar on 05/12/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import PovioKit

class ThrottlerTests: XCTestCase {
  
  func testShouldExecuteWhenDelayed() {
    let delay = 100
    let waiting = delay + 10
    let sut = Throttler(delay: .milliseconds(delay))
    let expectation = self.expectation(description: "Executed")
    var output: [String] = []
    sut.execute {
      output.append("A")
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(waiting)) {
      expectation.fulfill()
    }
    waitForExpectations(timeout: Double(waiting + 10) / 1000, handler: nil)
    XCTAssertEqual(output, ["A"])
  }
  
  func testShouldNotExecuteWhenCanceled() {
    let delay = 100
    let waiting = delay + 10
    let sut = Throttler(delay: .milliseconds(delay))
    let expectation = self.expectation(description: "delay")
    var output: [String] = []
    sut.execute {
      output.append("A")
    }
    sut.cancelPendingJob()
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(waiting)) {
      expectation.fulfill()
    }
    waitForExpectations(timeout: Double(waiting + 10) / 1000, handler: nil)
    XCTAssertEqual(output, [])
  }
  
  func testShouldSkipExecutionWhenThereIsAnotherOne() {
    let delay = 100
    let waiting = delay + 10
    let sut = Throttler(delay: .milliseconds(delay))
    let expectation = self.expectation(description: "delay")
    var output: [String] = []
    sut.execute {
      output.append("A")
    }
    sut.execute {
      output.append("B")
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(waiting)) {
      expectation.fulfill()
    }
    waitForExpectations(timeout: Double(waiting + 10) / 1000, handler: nil)
    XCTAssertEqual(output, ["B"])
  }
  
  func testShouldExecuteTwiceWhenTwoSequentialCalls() {
    let delay = 100
    let waiting = 2 * delay + 10
    let sut = Throttler(delay: .milliseconds(delay))
    let expectation = self.expectation(description: "delay")
    var output: [String] = []
    sut.execute {
      output.append("A")
      sut.execute {
        output.append("B")
      }
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(waiting)) {
      expectation.fulfill()
    }
    waitForExpectations(timeout: Double(waiting + 10) / 1000, handler: nil)
    XCTAssertEqual(output, ["A", "B"])
  }
}
