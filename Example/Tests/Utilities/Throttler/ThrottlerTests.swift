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
    let sut = MockedThrottler(delay: .milliseconds(delay))
    let expectation = self.expectation(description: "delay")
    sut.execute(withId: "A") {
      expectation.fulfill()
    }
    XCTAssertEqual(sut.outputIdentifiers, [])
    waitForExpectations(timeout: Double(waiting + 10) / 1000, handler: nil)
    XCTAssertEqual(sut.outputIdentifiers, ["A"])
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
    waitForExpectations(timeout: Double(waiting) / 1000, handler: nil)
    XCTAssertEqual(output, [])
  }
  
  func testShouldSkipExecutionWhenThereIsAnotherOne() {
    let delay = 100
    let waiting = delay + 10
    let sut = MockedThrottler(delay: .milliseconds(delay))
    let expectation = self.expectation(description: "delay")
    sut.execute(withId: "A") {}
    sut.execute(withId: "B") {
      expectation.fulfill()
    }
    waitForExpectations(timeout: Double(waiting) / 1000, handler: nil)
    XCTAssertEqual(sut.outputIdentifiers, ["B"])
  }
  
  func testShouldExecuteTwiceWhenTwoSequentialCalls() {
    let delay = 100
    let waiting = 2 * delay + 10
    let sut = MockedThrottler(delay: .milliseconds(delay))
    let expectation = self.expectation(description: "delay")
    sut.execute(withId: "A") {
      sut.execute(withId: "B") {
        expectation.fulfill()
      }
    }
    waitForExpectations(timeout: Double(waiting) / 1000, handler: nil)
    XCTAssertEqual(sut.outputIdentifiers, ["A", "B"])
  }
}

private class MockedThrottler: Throttler {
  var outputIdentifiers: [String] = []
  
  func execute(withId id: String, completion: @escaping () -> Void) {
    execute {
      self.outputIdentifiers.append(id)
      completion()
    }
  }
}
