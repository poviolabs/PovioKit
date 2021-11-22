//
//  BroadcastTests.swift
//  PovioKit_Tests
//
//  Created by Klemen Zagar on 05/12/2019.
//  Copyright © 2021 Povio Inc. All rights reserved.
//

import XCTest
@testable import PovioKit

class BroadcastTests: XCTestCase {

  func testWillNotifyListenerWhenBroadcastInvoked() {
    let sut = Broadcast<MockedProtocol>()
    let listener = MockedListener()
    sut.add(delegate: listener)
    sut.invoke { $0.run() }
    XCTAssertEqual(listener.executingCount, 1, "Listener should be notified only once")
  }
  
  func testWillNotifyListenerWhenBroadcastInvokedOnMainQueue() {
    let sut = Broadcast<MockedProtocol>()
    let listener = MockedListener()
    let expectation = self.expectation(description: "delay")
    
    sut.add(delegate: listener)
    sut.invoke(on: .main) {
      $0.run()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 1, handler: nil)
    XCTAssertEqual(listener.executingCount, 1, "Listener should be notified exactly once")
  }
  
  func testListenerNotifiedOnMainThreadWhenBroadcastInvokedOnMainThread() {
    let sut = Broadcast<MockedProtocol>()
    let listener = MockedListener()
    let expectation = self.expectation(description: "delay")
    var invokedOnMainThread = false
    sut.add(delegate: listener)
    sut.invoke(on: .main) {
      $0.run()
      expectation.fulfill()
      invokedOnMainThread = Thread.current.isMainThread
    }
    waitForExpectations(timeout: 1, handler: nil)
    XCTAssert(invokedOnMainThread, "Listener should be notified on the main thread")
  }
  
  func testWillNotifyListenerTwiceWhenBroadcastInvokedTwice() {
    let sut = Broadcast<MockedProtocol>()
    let listener = MockedListener()
    sut.add(delegate: listener)
    sut.invoke { $0.run() }
    sut.invoke { $0.run() }
    XCTAssertEqual(listener.executingCount, 2, "Listener should be notified exactly two times")
  }
  
  func testWontNotifyListenerWhenBroadcastClearedAndInvoked() {
    let sut = Broadcast<MockedProtocol>()
    let listener = MockedListener()
    sut.add(delegate: listener)
    sut.clear()
    sut.invoke { $0.run() }
    XCTAssertEqual(listener.executingCount, 0, "Listener should not be notified when broadcast is cleared before invokation")
  }
  
  func testWillNotifyTwoListenersWhenBroadcastInvoked() {
    let sut = Broadcast<MockedProtocol>()
    let listener = MockedListener()
    let anotherlistener = MockedListener()
    sut.add(delegate: listener)
    sut.add(delegate: anotherlistener)
    sut.invoke { $0.run() }
    XCTAssertEqual(listener.executingCount, 1, "First listener should be notified only once")
    XCTAssertEqual(anotherlistener.executingCount, 1, "Second listener should be notified only once")
  }
  
  func testWontNotifyListenerWhenUnsubscribed() {
    let sut = Broadcast<MockedProtocol>()
    let listener = MockedListener()
    sut.add(delegate: listener)
    sut.remove(delegate: listener)
    sut.invoke { $0.run() }
    XCTAssertEqual(listener.executingCount, 0, "Listener should not be notified when not subscrubed to broadcast")
  }
  
}

private protocol MockedProtocol {
  func run()
}

private class MockedListener: MockedProtocol {
  var executingCount = 0
  
  func run() {
    executingCount += 1
  }
}
