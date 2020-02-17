//
//  ThrottlerTests.swift
//  PovioKit_Tests
//
//  Created by Klemen Zagar on 05/12/2019.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import XCTest
@testable import PovioKit

class ThrottlerTests: XCTestCase {
  
  func testShouldExecuteWhenDelayed() {
    let delay = 100
    let waiting = delay + 10
    let throttler = MockedThrottler(delay: .milliseconds(delay))
    let expectation = self.expectation(description: "delay")
    throttler.execute(withId: "A") {
      expectation.fulfill()
    }
    XCTAssertEqual(throttler.outputIdentifiers, [])
    waitForExpectations(timeout: Double(waiting) / 1000, handler: nil)
    XCTAssertEqual(throttler.outputIdentifiers, ["A"])
  }
  
  func testShouldNotExecuteWhenCanceled() {
    let delay = 100
    let waiting = delay + 10
    let throttler = MockedThrottler(delay: .milliseconds(delay))
    let expectation = self.expectation(description: "delay")
    throttler.execute { }
    throttler.cancelPendingJob()
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(waiting)) {
      expectation.fulfill()
    }
    waitForExpectations(timeout: Double(waiting) / 1000, handler: nil)
    XCTAssertEqual(throttler.outputIdentifiers, [])
  }
  
  func testShouldSkipExecutionWhenThereIsAnotherOne() {
    let delay = 100
    let waiting = delay + 10
    let throttler = MockedThrottler(delay: .milliseconds(delay))
    let expectation = self.expectation(description: "delay")
    throttler.execute(withId: "A") {}
    throttler.execute(withId: "B") {
      expectation.fulfill()
    }
    waitForExpectations(timeout: Double(waiting) / 1000, handler: nil)
    XCTAssertEqual(throttler.outputIdentifiers, ["B"])
  }
  
  func testShouldExecuteTwiceWhenTwoSequentialCalls() {
    let delay = 100
    let waiting = 2 * delay + 10
    let throttler = MockedThrottler(delay: .milliseconds(delay))
    let expectation = self.expectation(description: "delay")
    throttler.execute(withId: "A") {
      throttler.execute(withId: "B") {
        expectation.fulfill()
      }
    }
    waitForExpectations(timeout: Double(waiting) / 1000, handler: nil)
    XCTAssertEqual(throttler.outputIdentifiers, ["A", "B"])
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
  
  func execute(withId id: String, completion: @escaping () -> Void, expectedCompletion: @escaping () -> Void) {
    execute(withId: id, completion: completion)
    execute {
      self.outputIdentifiers.append(id)
      completion()
    }
  }
}
