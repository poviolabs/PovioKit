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
      promise.then { count += 1 }
      promise.resolve(on: nil)
      promise.resolve(on: nil)
      XCTAssertEqual(count, 1)
    }
    
    do {
      let promise = Promise<()>()
      var count = 0
      promise.catch { _ in count += 1 }
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
    promise.then { ex1.fulfill() }
    promise.finally { _ in  ex2.fulfill() }
    
    promise = Promise(reject: NSError())
    promise.catch { _ in ex3.fulfill() }
    promise.finally { _ in ex4.fulfill() }
    
    wait(for: [ex1, ex2, ex3, ex4], timeout: 1)
  }
  
  func testChainResolvedOnMainThread() {
    let ex1 = expectation(description: "")
    let ex2 = expectation(description: "")
    0.asyncPromise
      .chain(on: .main) { $0.asyncPromise }
      .then { _ in
        XCTAssertTrue(Thread.isMainThread)
        ex1.fulfill()
      }
    0.asyncFailurePromise
      .chain(on: .main) { $0.asyncPromise }
      .catch { _ in
        XCTAssertTrue(Thread.isMainThread)
        ex2.fulfill()
      }
    wait(for: [ex1, ex2], timeout: 1)
  }
  
  func testAllResolvedOnMainThread() {
    let ex1 = expectation(description: "")
    let ex2 = expectation(description: "")
    all(on: .main, promises: [0.asyncPromise, 1.asyncPromise])
      .then { _ in
        XCTAssertTrue(Thread.isMainThread)
        ex1.fulfill()
      }
    all(on: .main, promises: [0.asyncPromise, 1.asyncFailurePromise])
      .catch { _ in
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
      .then {
        XCTAssertEqual(30, $0)
        ex.fulfill()
      }
    waitForExpectations(timeout: 1)
  }
  
  func testChainInfix() {
    let ex = expectation(description: "")
    (10.asyncPromise >>- { val in
      (val + 20).asyncPromise
    }).then {
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
      .catch {
        XCTAssertTrue($0 is DummyError)
        ex1.fulfill()
      }
    DummyError().asyncPromise
      .chain { 10.asyncPromise }
      .catch {
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
      .then {
        XCTAssertEqual(20, $0)
        ex1.fulfill()
      }
    10.asyncPromise
      .chainResult { _ in Result<Int, Error>.failure(DummyError()) }
      .catch {
        XCTAssertTrue($0 is DummyError)
        ex2.fulfill()
      }
    waitForExpectations(timeout: 1)
  }
  
  func testMap() {
    let ex = expectation(description: "")
    10.asyncPromise
      .map(with: String.init)
      .then {
        XCTAssertEqual("10", $0)
        ex.fulfill()
      }
    waitForExpectations(timeout: 1)
  }
  
  func testMapInfix() {
    let ex = expectation(description: "")
    (10.asyncPromise <^> String.init)
      .then {
        XCTAssertEqual("10", $0)
        ex.fulfill()
      }
    waitForExpectations(timeout: 1)
  }
  
  func testMapThrows() {
    let ex = expectation(description: "")
    10.asyncPromise
      .map { _ in throw NSError() }
      .catch { _ in
        ex.fulfill()
      }
    waitForExpectations(timeout: 1)
  }
  
  func testMapError() {
    let ex = expectation(description: "")
    NSError().asyncPromise
      .mapError { _ in DummyError() }
      .catch {
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
      .then {
        XCTAssertEqual(10, $0)
        ex1.fulfill()
      }
    "a".asyncPromise
      .compactMap { Int($0) }
      .catch { _ in
        ex2.fulfill()
      }
    "a".asyncPromise
      .compactMap(or: DummyError()) { Int($0) }
      .catch {
        XCTAssertTrue($0 is DummyError)
        ex3.fulfill()
      }
    waitForExpectations(timeout: 1)
  }
  
  func testAlternative() {
    let ex1 = expectation(description: "")
    let ex2 = expectation(description: "")
    (1.asyncPromise <|> 2.asyncPromise)
      .then {
        XCTAssertEqual(1, $0)
        ex1.fulfill()
      }
    (NSError().asyncPromise(Int.self) <|> 2.asyncPromise)
      .then {
        XCTAssertEqual(2, $0)
        ex2.fulfill()
      }
    waitForExpectations(timeout: 1)
  }
  
  func testDiscard() {
    let ex1 = expectation(description: "")
    let ex2 = expectation(description: "")
    (10.asyncPromise *> false.asyncPromise)
      .then {
        XCTAssertEqual(false, $0)
        ex1.fulfill()
      }
    (10.asyncPromise <* false.asyncPromise)
      .then {
        XCTAssertEqual(10, $0)
        ex2.fulfill()
      }
    waitForExpectations(timeout: 1)
  }
  
  func testAndPromise() {
    let ex = expectation(description: "")
    10.asyncPromise.and(20.asyncPromise)
      .then {
        XCTAssertEqual(10, $0.0)
        XCTAssertEqual(20, $0.1)
        ex.fulfill()
      }
    waitForExpectations(timeout: 1)
  }
  
  func testAnd() {
    let ex = expectation(description: "")
    10.asyncPromise.and(20)
      .then {
        XCTAssertEqual(10, $0.0)
        XCTAssertEqual(20, $0.1)
        ex.fulfill()
      }
    waitForExpectations(timeout: 1)
  }
  
  func testAllListAsync() {
    let range = (0...5)
    let ex = expectation(description: "")
    ex.expectedFulfillmentCount = range.count
    let promises = range.map { $0.asyncPromise }
    all(promises: promises)
      .then { values in
        range.forEach {
          XCTAssertEqual($0, values[$0])
          ex.fulfill()
        }
      }
    waitForExpectations(timeout: 2)
  }
  
  func testAllList() {
    let ex = expectation(description: "")
    let promises = (0...5).map { $0.promise }
    all(promises: promises)
      .then { values in
        (0...5).forEach { XCTAssertEqual($0, values[$0]) }
        ex.fulfill()
      }
    waitForExpectations(timeout: 1)
  }
  
  func testAllEmptyList() {
    let ex = expectation(description: "")
    let promises: [Promise<Int>] = []
    all(promises: promises)
      .then { values in
        XCTAssertTrue(values.isEmpty)
        ex.fulfill()
      }
    waitForExpectations(timeout: 1)
  }
  
  func testAllTwo() {
    let ex = expectation(description: "")
    all(
      0.asyncPromise,
      1.asyncPromise
    ).then { values in
      XCTAssertEqual(values.0, 0)
      XCTAssertEqual(values.1, 1)
      ex.fulfill()
    }
    waitForExpectations(timeout: 1)
  }
  
  func testAllThree() {
    let ex = expectation(description: "")
    all(
      0.asyncPromise,
      1.asyncPromise,
      2.asyncPromise
    ).then { values in
      XCTAssertEqual(values.0, 0)
      XCTAssertEqual(values.1, 1)
      XCTAssertEqual(values.2, 2)
      ex.fulfill()
    }
    waitForExpectations(timeout: 1)
  }
  
  func testAllFour() {
    let ex = expectation(description: "")
    all(
      0.asyncPromise,
      1.asyncPromise,
      2.asyncPromise,
      3.asyncPromise
    ).then { values in
      XCTAssertEqual(values.0, 0)
      XCTAssertEqual(values.1, 1)
      XCTAssertEqual(values.2, 2)
      XCTAssertEqual(values.3, 3)
      ex.fulfill()
    }
    waitForExpectations(timeout: 1)
  }
  
  func testAllFive() {
    let ex = expectation(description: "")
    all(
      0.asyncPromise,
      1.asyncPromise,
      2.asyncPromise,
      3.asyncPromise,
      4.asyncPromise
    ).then { values in
      XCTAssertEqual(values.0, 0)
      XCTAssertEqual(values.1, 1)
      XCTAssertEqual(values.2, 2)
      XCTAssertEqual(values.3, 3)
      XCTAssertEqual(values.4, 4)
      ex.fulfill()
    }
    waitForExpectations(timeout: 1)
  }
  
  func testAnyListAsync() {
    let range = (0...5)
    let ex = expectation(description: "")
    ex.expectedFulfillmentCount = range.count
    let promises = range.map { $0.asyncPromise }
    all(promises: promises)
      .then { values in
        range.forEach {
          XCTAssertEqual($0, values[$0])
          ex.fulfill()
        }
      }
    waitForExpectations(timeout: 2)
  }
  
  func testAnyList() {
    let ex = expectation(description: "")
    let promises = (0...5).map { $0.promise }
    all(promises: promises)
      .then { values in
        (0...5).forEach { XCTAssertEqual($0, values[$0]) }
        ex.fulfill()
      }
    waitForExpectations(timeout: 1)
  }
  
  func testAnyEmptyList() {
    let ex = expectation(description: "")
    any(promises: [Promise<Int>]())
      .catch { _ in
        ex.fulfill()
      }
    waitForExpectations(timeout: 1)
  }
  
  func testAnyTwo() {
    let ex = expectation(description: "")
    any(
      NSError().asyncPromise(Int.self),
      2.promise
    ).then { values in
      XCTAssertEqual(values.0, nil)
      XCTAssertEqual(values.1, 2)
      ex.fulfill()
    }
    waitForExpectations(timeout: 1)
  }
  
  func testAnyThree() {
    let ex = expectation(description: "")
    any(
      0.promise,
      NSError().asyncPromise(Int.self),
      2.promise
    ).then { values in
      XCTAssertEqual(values.0, 0)
      XCTAssertEqual(values.1, nil)
      XCTAssertEqual(values.2, 2)
      ex.fulfill()
    }
    waitForExpectations(timeout: 1)
  }
  
  func testAnyFour() {
    let ex = expectation(description: "")
    any(
      0.promise,
      1.promise,
      NSError().asyncPromise(Int.self),
      3.promise
    ).then { values in
      XCTAssertEqual(values.0, 0)
      XCTAssertEqual(values.1, 1)
      XCTAssertEqual(values.2, nil)
      XCTAssertEqual(values.3, 3)
      ex.fulfill()
    }
    waitForExpectations(timeout: 1)
  }
  
  func testAnyFive() {
    let ex = expectation(description: "")
    any(
      0.promise,
      1.promise,
      2.promise,
      NSError().asyncPromise(Int.self),
      4.promise
    ).then { values in
      XCTAssertEqual(values.0, 0)
      XCTAssertEqual(values.1, 1)
      XCTAssertEqual(values.2, 2)
      XCTAssertEqual(values.3, nil)
      XCTAssertEqual(values.4, 4)
      ex.fulfill()
    }
    waitForExpectations(timeout: 1)
  }
  
  func testAnyFails() {
    let ex = expectation(description: "")
    any(promises: [
      NSError().asyncPromise(Int.self),
      NSError().asyncPromise(Int.self),
      NSError().asyncPromise(Int.self),
      NSError().asyncPromise(Int.self),
      NSError().asyncPromise(Int.self),
    ]).catch { _ in
      ex.fulfill()
    }
    waitForExpectations(timeout: 1)
  }
  
  func testMapValues() {
    let ex = expectation(description: "")
    [1, 2, 3].asyncPromise
      .mapValues { $0 * 2 }
      .then {
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
      .then {
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
      .then {
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
      .then {
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
      .then {
        XCTAssertEqual($0, 15)
        ex1.fulfill()
      }
    [1, 2, 3, 4, 5].asyncPromise
      .reduceValues(20, +)
      .then {
        XCTAssertEqual($0, 35)
        ex2.fulfill()
      }
    Promise
      .reduce(0, [1, 2, 3, 4, 5].map { $0.asyncPromise }, +)
      .then {
        XCTAssertEqual(15, $0)
        ex3.fulfill()
      }
    waitForExpectations(timeout: 1)
  }
  
  func testSortedValues() {
    let ex = expectation(description: "")
    [8, 2, 1, 5, 10].asyncPromise
      .sortedValues(by: <)
      .then {
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
      .then {
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
      .then {
        XCTAssertEqual(10, $0)
        ex1.fulfill()
      }
    Optional<Int>.none.asyncPromise
      .unwrap(or: DummyError())
      .catch {
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
      .then {
        XCTAssertEqual(1, $0)
        ex1.fulfill()
      }
    false.asyncPromise
      .chainIf(
        true: .value(1),
        false: .value(0))
      .then {
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
      .then {
        XCTAssertEqual(1, $0)
        ex1.fulfill()
      }
    false.asyncPromise
      .mapIf(
        true: 1,
        false: 0)
      .then {
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
      .then {
        XCTAssertEqual(1, $0)
        ex1.fulfill()
      }
    1.asyncPromise
      .chainIf(
        transform: { _ in false },
        true: .value(1),
        false: .value(0))
      .then {
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
      .then {
        XCTAssertEqual(1, $0)
        ex1.fulfill()
      }
    1.asyncPromise
      .mapIf(
        transform: { _ in false },
        true: 1,
        false: 0)
      .then {
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
