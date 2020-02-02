//
//  PromiseTests.swift
//  PovioKit_Tests
//
//  Created by Toni Kocjan on 31/01/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
@testable import PovioKit

class PromiseTests: XCTestCase {
  // Covering some of the A+ spec (https://github.com/promises-aplus/promises-spec)
  
  func testIsFullfiled() {
    var promise = Promise(fulfill: 10)
    XCTAssertTrue(promise.isFulfilled)
    XCTAssertFalse(promise.isRejected)
    XCTAssertFalse(promise.isAwaiting)
    
    promise = Promise<Int>.value(10)
    XCTAssertTrue(promise.isFulfilled)
    XCTAssertFalse(promise.isRejected)
    XCTAssertFalse(promise.isAwaiting)
  }
  
  func testIsRejected() {
    var promise = Promise<()>(reject: NSError())
    XCTAssertFalse(promise.isFulfilled)
    XCTAssertTrue(promise.isRejected)
    XCTAssertFalse(promise.isAwaiting)
    
    promise = Promise<()>.error(NSError())
    XCTAssertFalse(promise.isFulfilled)
    XCTAssertTrue(promise.isRejected)
    XCTAssertFalse(promise.isAwaiting)
  }
  
  func testIsAwaiting() {
    let promise = Promise<()>()
    XCTAssertTrue(promise.isAwaiting)
    XCTAssertFalse(promise.isFulfilled)
    XCTAssertFalse(promise.isRejected)
    
    promise.resolve()
    XCTAssertFalse(promise.isAwaiting)
  }
  
  func testRejectedTransition() {
    let promise = Promise<()>(reject: NSError())
    XCTAssertTrue(promise.isRejected)
    promise.resolve()
    XCTAssertTrue(promise.isRejected)
    XCTAssertFalse(promise.isFulfilled)
  }
  
  func testResolvedTransition() {
    let promise = Promise<()>(fulfill: ())
    XCTAssertTrue(promise.isFulfilled)
    promise.reject(with: NSError())
    XCTAssertTrue(promise.isFulfilled)
    XCTAssertFalse(promise.isRejected)
  }
  
  func testObserversNotifiedOnceOnly() {
    do {
      let promise = Promise<()>()
      var count = 0
      promise.onSuccess { count += 1 }
      promise.resolve()
      promise.resolve()
      XCTAssertEqual(count, 1)
    }
    
    do {
      let promise = Promise<()>()
      var count = 0
      promise.onFailure { _ in count += 1 }
      promise.reject(with: NSError())
      promise.reject(with: NSError())
      XCTAssertEqual(count, 1)
    }
  }
  
  func testObserverCalledOnResolvedPromise() {
    let ex1 = expectation(description: "")
    let ex2 = expectation(description: "")
    let ex3 = expectation(description: " ")
    let ex4 = expectation(description: " ")
    
    var promise = Promise(fulfill: ())
    promise.onSuccess { ex1.fulfill() }
    promise.observe { _ in  ex2.fulfill() }
    
    promise = Promise(reject: NSError())
    promise.onFailure { _ in ex3.fulfill() }
    promise.observe { _ in  ex4.fulfill() }
    
    waitForExpectations(timeout: 1)
  }
}

extension PromiseTests {
  func testChain() {
    let ex = expectation(description: "")
    10.asyncPromise
      .chain { ($0 + 20).asyncPromise }
      .onSuccess {
        XCTAssertEqual(30, $0)
        ex.fulfill()
    }
    wait(for: [ex], timeout: 1)
  }
  
  func testMap() {
    let ex = expectation(description: "")
    10.asyncPromise
      .map { String($0) }
      .onSuccess {
        XCTAssertEqual("10", $0)
        ex.fulfill()
    }
    wait(for: [ex], timeout: 1)
  }
  
  func testMapThrows() {
    let ex = expectation(description: "")
    10.asyncPromise
      .map { _ in throw NSError() }
      .onFailure { _ in
        ex.fulfill()
    }
    wait(for: [ex], timeout: 1)
  }
  
  func testCompactMap() {
    let ex1 = expectation(description: "")
    let ex2 = expectation(description: "")
    "10".asyncPromise
      .compactMap { Int($0) }
      .onSuccess {
        XCTAssertEqual(10, $0)
        ex1.fulfill()
    }
    "a".asyncPromise
      .compactMap { Int($0) }
      .onFailure { _ in
        ex2.fulfill()
    }
    wait(for: [ex1, ex2], timeout: 1)
  }
  
  func testCombineListAsync() {
    let ex = expectation(description: "")
    let promises = (0...5).map { $0.asyncPromise }
    combine(promises: promises)
      .onSuccess { values in
        (0...5).forEach { XCTAssertEqual($0, values[$0]) }
        ex.fulfill()
    }
    wait(for: [ex], timeout: 1)
  }
  
  func testCombineList() {
    let ex = expectation(description: "")
    let promises = (0...5).map { $0.promise }
    combine(promises: promises)
      .onSuccess { values in
        (0...5).forEach { XCTAssertEqual($0, values[$0]) }
        ex.fulfill()
    }
    wait(for: [ex], timeout: 1)
  }
  
  func testCombineTwo() {
    let ex = expectation(description: "")
    combine(0.asyncPromise, 1.asyncPromise)
      .onSuccess { values in
        XCTAssertEqual(values.0, 0)
        XCTAssertEqual(values.1, 1)
        ex.fulfill()
    }
    wait(for: [ex], timeout: 1)
  }
  
  func testCombineThree() {
    let ex = expectation(description: "")
    combine(0.asyncPromise,
            1.asyncPromise,
            2.asyncPromise)
      .onSuccess { values in
        XCTAssertEqual(values.0, 0)
        XCTAssertEqual(values.1, 1)
        XCTAssertEqual(values.2, 2)
        ex.fulfill()
    }
    wait(for: [ex], timeout: 1)
  }
  
  func testCombineFour() {
    let ex = expectation(description: "")
    combine(0.asyncPromise,
            1.asyncPromise,
            2.asyncPromise,
            3.asyncPromise)
      .onSuccess { values in
        XCTAssertEqual(values.0, 0)
        XCTAssertEqual(values.1, 1)
        XCTAssertEqual(values.2, 2)
        XCTAssertEqual(values.3, 3)
        ex.fulfill()
    }
    wait(for: [ex], timeout: 1)
  }
  
  func testCombineFive() {
    let ex = expectation(description: "")
    combine(0.asyncPromise,
            1.asyncPromise,
            2.asyncPromise,
            3.asyncPromise,
            4.asyncPromise)
      .onSuccess { values in
        XCTAssertEqual(values.0, 0)
        XCTAssertEqual(values.1, 1)
        XCTAssertEqual(values.2, 2)
        XCTAssertEqual(values.3, 3)
        XCTAssertEqual(values.4, 4)
        ex.fulfill()
    }
    wait(for: [ex], timeout: 1)
  }
  
  func testMapValues() {
    let ex = expectation(description: "")
    [1, 2, 3].asyncPromise
      .mapValues { $0 * 2 }
      .onSuccess {
        XCTAssertEqual($0[0], 2)
        XCTAssertEqual($0[1], 4)
        XCTAssertEqual($0[2], 6)
        ex.fulfill()
    }
    wait(for: [ex], timeout: 1)
  }
  
  func testCompactMapValues() {
    let ex = expectation(description: "")
    ["1", "2", "a", "3"].asyncPromise
      .compactMapValues { Int($0) }
      .onSuccess {
        XCTAssertEqual($0[0], 1)
        XCTAssertEqual($0[1], 2)
        XCTAssertEqual($0[2], 3)
        ex.fulfill()
    }
    wait(for: [ex], timeout: 1)
  }
  
  func testFlatMapValues() {
    let ex = expectation(description: "")
    [1, 2, 3].asyncPromise
      .flatMapValues { $0.asyncPromise }
      .onSuccess {
        XCTAssertEqual($0[0], 1)
        XCTAssertEqual($0[1], 2)
        XCTAssertEqual($0[2], 3)
        ex.fulfill()
    }
    wait(for: [ex], timeout: 1)
  }
  
  func testFilterValues() {
    let ex = expectation(description: "")
    [1, 2, 3, 4, 5, 6].asyncPromise
      .filterValues { $0 % 2 == 0 }
      .onSuccess {
        XCTAssertEqual($0[0], 2)
        XCTAssertEqual($0[1], 4)
        XCTAssertEqual($0[2], 6)
        ex.fulfill()
    }
    wait(for: [ex], timeout: 1)
  }
  
  func testReduceValues() {
    let ex1 = expectation(description: "")
    let ex2 = expectation(description: "")
    [1, 2, 3, 4, 5].asyncPromise
      .reduceValues(+)
      .onSuccess {
        XCTAssertEqual($0, 15)
        ex1.fulfill()
    }
    [1, 2, 3, 4, 5].asyncPromise
      .reduceValues(20, +)
      .onSuccess {
        XCTAssertEqual($0, 35)
        ex2.fulfill()
    }
    wait(for: [ex1, ex2], timeout: 1)
  }
  
  func testSortedValues() {
    let ex = expectation(description: "")
    [8, 2, 1, 5, 10].asyncPromise
      .sortedValues(by: <)
      .onSuccess {
        XCTAssertEqual($0[0], 1)
        XCTAssertEqual($0[1], 2)
        XCTAssertEqual($0[2], 5)
        XCTAssertEqual($0[3], 8)
        XCTAssertEqual($0[4], 10)
        ex.fulfill()
    }
    wait(for: [ex], timeout: 1)
  }
  
  func testDecodable() {
    let ex = expectation(description: "")
    Promise<()>.value(())
      .map { _ in try JSONSerialization.data(withJSONObject: ["x": 10, "y": 20], options: []) }
      .decode(type: Point.self, decoder: JSONDecoder())
      .onSuccess {
        XCTAssertEqual($0.x, 10)
        XCTAssertEqual($0.y, 20)
        ex.fulfill()
    }
    wait(for: [ex], timeout: 1)
  }
}

extension Int {
  var asyncPromise: Promise<Self> {
    Promise { seal in
      DispatchQueue.main.async {
        seal.resolve(with: self)
      }
    }
  }
  
  var promise: Promise<Self> {
    Promise.value(self)
  }
}

extension Sequence {
  var asyncPromise: Promise<Self> {
    Promise { seal in
      DispatchQueue.global().asyncAfter(deadline: .now() + 0.05) {
        seal.resolve(with: self)
      }
    }
  }
  
  var promise: Promise<Self> {
    Promise.value(self)
  }
}

struct Point: Decodable {
  let x: Int
  let y: Int
}
