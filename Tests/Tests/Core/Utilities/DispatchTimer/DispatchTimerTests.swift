//
//  DispatchTimerTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomazin on 19/09/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import XCTest
import PovioKit

final class DispatchTimerTests: XCTestCase {
  func test_dispatchTimer_instance_noRepeating() {
    let timer = DispatchTimer()
    XCTAssertFalse(timer.isActive)
    
    let promise = expectation(description: "Wait for timer...")
    timer.schedule(interval: .milliseconds(100), repeating: false, on: .main) {
      promise.fulfill()
    }
    
    XCTAssertTrue(timer.isActive)
    waitForExpectations(timeout: 0.5)
    XCTAssertFalse(timer.isActive)
  }
  
  func test_dispatchTimer_instance_repeating() {
    let timer = DispatchTimer()
    XCTAssertFalse(timer.isActive)
    
    let promise = expectation(description: "Wait for timer...")
    promise.expectedFulfillmentCount = 5
    
    var repeatCount = 0
    timer.schedule(interval: .milliseconds(50), repeating: true, on: .main) {
      promise.fulfill()
      repeatCount += 1
      if repeatCount >= 5 {
        timer.stop()
      }
    }
    
    XCTAssertTrue(timer.isActive)
    waitForExpectations(timeout: 0.5)
    XCTAssertFalse(timer.isActive)
  }
  
  func test_dispatchTimer_static_noRepeating() {
    let promise = expectation(description: "Wait for timer...")
    let timer = DispatchTimer.scheduled(interval: .milliseconds(100), repeating: false, on: .main) {
      promise.fulfill()
    }
    
    XCTAssertTrue(timer.isActive)
    waitForExpectations(timeout: 0.5)
    XCTAssertFalse(timer.isActive)
  }
  
  func test_dispatchTimer_static_repeating() {
    let promise = expectation(description: "Wait for timer...")
    promise.expectedFulfillmentCount = 5
    
    var repeatCount = 0
    let timer = DispatchTimer.scheduled(interval: .milliseconds(50), repeating: true, on: .main) {
      repeatCount += 1
      promise.fulfill()
    }
    
    // kickoff another timer to continuosly monitor static instance so we can stop it at the desired `repeatCount`
    let secondTimer = DispatchTimer()
    secondTimer.schedule(interval: .milliseconds(25), repeating: true, on: .main) {
      if repeatCount >= 5 {
        timer.stop()
        secondTimer.stop()
      }
    }
    
    XCTAssertTrue(timer.isActive)
    waitForExpectations(timeout: 0.5)
    XCTAssertFalse(timer.isActive)
  }
  
  func test_dispatchTimer_stop() {
    let timer = DispatchTimer()
    XCTAssertFalse(timer.isActive)
    
    timer.schedule(interval: .milliseconds(100), repeating: false, on: .main, nil)
    
    XCTAssertTrue(timer.isActive)
    timer.stop()
    XCTAssertFalse(timer.isActive)
  }
}
