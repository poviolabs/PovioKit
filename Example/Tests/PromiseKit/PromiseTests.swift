//
//  PromiseTests.swift
//  PovioKit_Tests
//
//  Created by Toni Kocjan on 31/01/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
@testable import PovioKitPromise

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
      promise.resolve(on: nil)
      promise.resolve(on: nil)
      XCTAssertEqual(count, 1)
    }
    
    do {
      let promise = Promise<()>()
      var count = 0
      promise.onFailure { _ in count += 1 }
      promise.reject(with: NSError(), on: nil)
      promise.reject(with: NSError(), on: nil)
      XCTAssertEqual(count, 1)
    }
  }
  
  func testObserverCalledOnResolvedPromise() {
    let ex1 = expectation(description: "")
    let ex2 = expectation(description: "")
    let ex3 = expectation(description: "")
    let ex4 = expectation(description: "")
    
    var promise = Promise(fulfill: ())
    promise.onSuccess { ex1.fulfill() }
    promise.observe { _ in  ex2.fulfill() }
    
    promise = Promise(reject: NSError())
    promise.onFailure { _ in ex3.fulfill() }
    promise.observe { _ in  ex4.fulfill() }
    
    waitForExpectations(timeout: 1)
  }
  
  func testChainResolvedOnMainThread() {
    let ex1 = expectation(description: "")
    let ex2 = expectation(description: "")
    0.asyncPromise
      .chain(on: .main) { $0.asyncPromise }
      .onSuccess { _ in
        XCTAssertTrue(Thread.isMainThread)
        ex1.fulfill()
      }
    0.asyncFailurePromise
      .chain(on: .main) { $0.asyncPromise }
      .onFailure { _ in
        XCTAssertTrue(Thread.isMainThread)
        ex2.fulfill()
      }
    waitForExpectations(timeout: 1)
  }
  
  func testCombineResolvedOnMainThread() {
    let ex1 = expectation(description: "")
    let ex2 = expectation(description: "")
    combine(on: .main, promises: [0.asyncPromise, 1.asyncPromise])
      .onSuccess { _ in
        XCTAssertTrue(Thread.isMainThread)
        ex1.fulfill()
      }
    combine(on: .main, promises: [0.asyncPromise, 1.asyncFailurePromise])
      .onFailure { _ in
        XCTAssertTrue(Thread.isMainThread)
        ex2.fulfill()
      }
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
    waitForExpectations(timeout: 1)
  }
  
  func testChainInfix() {
    let ex = expectation(description: "")
    (10.asyncPromise >>- { val in
      (val + 20).asyncPromise
    }).onSuccess {
      XCTAssertEqual(30, $0)
      ex.fulfill()
    }
    waitForExpectations(timeout: 1)
  }
  
  func testChainError() {
    let ex1 = expectation(description: "")
    let ex2 = expectation(description: "")
    10.asyncPromise
      .chain { _ in Promise<Int>.error(DummyError()) }
      .onFailure {
        XCTAssertTrue($0 is DummyError)
        ex1.fulfill()
      }
    DummyError().asyncPromise
      .chain { 10.asyncPromise }
      .onFailure {
        XCTAssertTrue($0 is DummyError)
        ex2.fulfill()
      }
    waitForExpectations(timeout: 1)
  }
  
  func testChainResult() {
    let ex1 = expectation(description: "")
    let ex2 = expectation(description: "")
    10.asyncPromise
      .chainResult { Result<Int, Error>.success($0 * 2) }
      .onSuccess {
        XCTAssertEqual(20, $0)
        ex1.fulfill()
      }
    10.asyncPromise
      .chainResult { _ in Result<Int, Error>.failure(DummyError()) }
      .onFailure {
        XCTAssertTrue($0 is DummyError)
        ex2.fulfill()
      }
    waitForExpectations(timeout: 1)
  }
  
  func testMap() {
    let ex = expectation(description: "")
    10.asyncPromise
      .map(with: String.init)
      .onSuccess {
        XCTAssertEqual("10", $0)
        ex.fulfill()
      }
    waitForExpectations(timeout: 1)
  }
  
  func testMapInfix() {
    let ex = expectation(description: "")
    (10.asyncPromise <^> String.init).onSuccess {
      XCTAssertEqual("10", $0)
      ex.fulfill()
    }
    waitForExpectations(timeout: 1)
  }
  
  func testMapThrows() {
    let ex = expectation(description: "")
    10.asyncPromise
      .map { _ in throw NSError() }
      .onFailure { _ in
        ex.fulfill()
      }
    waitForExpectations(timeout: 1)
  }
  
  func testMapError() {
    let ex = expectation(description: "")
    NSError().asyncPromise
      .mapError { _ in DummyError() }
      .onFailure {
        XCTAssertTrue($0 is DummyError)
        ex.fulfill()
      }
    waitForExpectations(timeout: 1)
  }
  
  func testCompactMap() {
    let ex1 = expectation(description: "")
    let ex2 = expectation(description: "")
    let ex3 = expectation(description: "")
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
    "a".asyncPromise
      .compactMap(or: DummyError()) { Int($0) }
      .onFailure {
        XCTAssertTrue($0 is DummyError)
        ex3.fulfill()
      }
    waitForExpectations(timeout: 1)
  }
  
  func testAlternative() {
    let ex1 = expectation(description: "")
    let ex2 = expectation(description: "")
    (1.asyncPromise <|> 2.asyncPromise)
      .onSuccess {
        XCTAssertEqual(1, $0)
        ex1.fulfill()
      }
    (NSError().asyncPromise(Int.self) <|> 2.asyncPromise)
      .onSuccess {
        XCTAssertEqual(2, $0)
        ex2.fulfill()
      }
    waitForExpectations(timeout: 1)
  }
  
  func testDiscard() {
    let ex1 = expectation(description: "")
    let ex2 = expectation(description: "")
    (10.asyncPromise *> false.asyncPromise)
      .onSuccess {
        XCTAssertEqual(false, $0)
        ex1.fulfill()
      }
    (10.asyncPromise <* false.asyncPromise)
      .onSuccess {
        XCTAssertEqual(10, $0)
        ex2.fulfill()
      }
    waitForExpectations(timeout: 1)
  }
  
  func testAndPromise() {
    let ex = expectation(description: "")
    10.asyncPromise.and(20.asyncPromise)
      .onSuccess {
        XCTAssertEqual(10, $0.0)
        XCTAssertEqual(20, $0.1)
        ex.fulfill()
      }
    waitForExpectations(timeout: 1)
  }
  
  func testAnd() {
    let ex = expectation(description: "")
    10.asyncPromise.and(20)
      .onSuccess {
        XCTAssertEqual(10, $0.0)
        XCTAssertEqual(20, $0.1)
        ex.fulfill()
      }
    waitForExpectations(timeout: 1)
  }
  
  func testCombineListAsync() {
    let range = (0...5)
    let ex = expectation(description: "")
    ex.expectedFulfillmentCount = range.count
    let promises = range.map { $0.asyncPromise }
    combine(promises: promises)
      .onSuccess { values in
        range.forEach {
          XCTAssertEqual($0, values[$0])
          ex.fulfill()
        }
      }
    waitForExpectations(timeout: 2)
  }
  
  func testCombineList() {
    let ex = expectation(description: "")
    let promises = (0...5).map { $0.promise }
    combine(promises: promises)
      .onSuccess { values in
        (0...5).forEach { XCTAssertEqual($0, values[$0]) }
        ex.fulfill()
      }
    waitForExpectations(timeout: 1)
  }
  
  func testCombineEmptyList() {
    let ex = expectation(description: "")
    let promises: [Promise<Int>] = []
    combine(promises: promises)
      .onSuccess { values in
        XCTAssertTrue(values.isEmpty)
        ex.fulfill()
      }
    waitForExpectations(timeout: 1)
  }
  
  func testCombineTwo() {
    let ex = expectation(description: "")
    combine(0.asyncPromise, 1.asyncPromise)
      .onSuccess { values in
        XCTAssertEqual(values.0, 0)
        XCTAssertEqual(values.1, 1)
        ex.fulfill()
      }
    waitForExpectations(timeout: 1)
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
    waitForExpectations(timeout: 1)
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
    waitForExpectations(timeout: 1)
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
    waitForExpectations(timeout: 1)
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
    waitForExpectations(timeout: 1)
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
    waitForExpectations(timeout: 1)
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
    waitForExpectations(timeout: 1)
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
    waitForExpectations(timeout: 1)
  }
  
  func testReduceValues() {
    let ex1 = expectation(description: "")
    let ex2 = expectation(description: "")
    let ex3 = expectation(description: "")
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
    Promise
      .reduce(0, [1, 2, 3, 4, 5].map { $0.asyncPromise }, +)
      .onSuccess {
        XCTAssertEqual(15, $0)
        ex3.fulfill()
      }
    waitForExpectations(timeout: 1)
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
    waitForExpectations(timeout: 1)
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
    waitForExpectations(timeout: 1)
  }
  
  func testUnwrap() {
    let ex1 = expectation(description: "")
    let ex2 = expectation(description: "")
    Optional<Int>.some(10).asyncPromise
      .unwrap(or: DummyError())
      .onSuccess {
        XCTAssertEqual(10, $0)
        ex1.fulfill()
      }
    Optional<Int>.none.asyncPromise
      .unwrap(or: DummyError())
      .onFailure {
        XCTAssertTrue($0 is DummyError)
        ex2.fulfill()
      }
    waitForExpectations(timeout: 1)
  }
  
  func testChainIf() {
    let ex1 = expectation(description: "")
    let ex2 = expectation(description: "")
    true.asyncPromise
      .chainIf(
        true: .value(1),
        false: .value(0))
      .onSuccess {
        XCTAssertEqual(1, $0)
        ex1.fulfill()
      }
    false.asyncPromise
      .chainIf(
        true: .value(1),
        false: .value(0))
      .onSuccess {
        XCTAssertEqual(0, $0)
        ex2.fulfill()
      }
    waitForExpectations(timeout: 1)
  }
  
  func testMapIf() {
    let ex1 = expectation(description: "")
    let ex2 = expectation(description: "")
    true.asyncPromise
      .mapIf(
        true: 1,
        false: 0)
      .onSuccess {
        XCTAssertEqual(1, $0)
        ex1.fulfill()
      }
    false.asyncPromise
      .mapIf(
        true: 1,
        false: 0)
      .onSuccess {
        XCTAssertEqual(0, $0)
        ex2.fulfill()
      }
    waitForExpectations(timeout: 1)
  }
  
  func testChainIf2() {
    let ex1 = expectation(description: "")
    let ex2 = expectation(description: "")
    1.asyncPromise
      .chainIf(
        transform: { _ in true },
        true: .value(1),
        false: .value(0))
      .onSuccess {
        XCTAssertEqual(1, $0)
        ex1.fulfill()
      }
    1.asyncPromise
      .chainIf(
        transform: { _ in false },
        true: .value(1),
        false: .value(0))
      .onSuccess {
        XCTAssertEqual(0, $0)
        ex2.fulfill()
      }
    waitForExpectations(timeout: 1)
  }
  
  func testMapIf2() {
    let ex1 = expectation(description: "")
    let ex2 = expectation(description: "")
    1.asyncPromise
      .mapIf(
        transform: { _ in true },
        true: 1,
        false: 0)
      .onSuccess {
        XCTAssertEqual(1, $0)
        ex1.fulfill()
      }
    1.asyncPromise
      .mapIf(
        transform: { _ in false },
        true: 1,
        false: 0)
      .onSuccess {
        XCTAssertEqual(0, $0)
        ex2.fulfill()
      }
    waitForExpectations(timeout: 1)
  }
}

extension Int {
  var asyncPromise: Promise<Self> {
    after(.now() + 0.05, on: .global(), self)
  }
  
  var promise: Promise<Self> {
    .value(self)
  }
  
  var asyncFailurePromise: Promise<Self> {
    .init { seal in
      DispatchQueue.global().asyncAfter(deadline: .now() + 0.05) {
        seal.reject(with: NSError())
      }
    }
  }
}

extension Bool {
  var asyncPromise: Promise<Self> {
    after(.now() + 0.05, on: .global(), self)
  }
  
  var promise: Promise<Self> {
    .value(self)
  }
  
  var asyncFailurePromise: Promise<Self> {
    .init { seal in
      DispatchQueue.global().asyncAfter(deadline: .now() + 0.05) {
        seal.reject(with: NSError())
      }
    }
  }
}


extension Sequence {
  var asyncPromise: Promise<Self> {
    after(.now() + 0.05, on: .global(), self)
  }
  
  var promise: Promise<Self> {
    .value(self)
  }
}

extension Error {
  var promise: Promise<()> {
    .error(self)
  }
  
  var asyncPromise: Promise<()> {
    after(.now() + 0.05, on: .global()).map { throw self }
  }
  
  func asyncPromise<T>(_ type: T.Type) -> Promise<T> {
    after(.now() + 0.05, on: .global()).map { throw self }
  }
}

extension OptionalType {
  var asyncPromise: Promise<WrappedType?> {
    after(.now() + 0.05, on: .global()).map { self.wrapped }
  }
}

struct DummyError: Error {}

struct Point: Decodable {
  let x: Int
  let y: Int
}
