//
//  PromiseTests.swift
//  PovioKit
//
//  Created by Toni Kocjan on 31/01/2020.
//  Copyright © 2022 Povio Inc. All rights reserved.
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
    var promise = Promise<()>(reject: NSError.err)
    XCTAssertFalse(promise.isFulfilled)
    XCTAssertTrue(promise.isRejected)
    XCTAssertFalse(promise.isAwaiting)
    
    promise = Promise<()>.error(NSError.err)
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
    let promise = Promise<()>(reject: NSError.err)
    XCTAssertTrue(promise.isRejected)
    promise.resolve()
    XCTAssertTrue(promise.isRejected)
    XCTAssertFalse(promise.isFulfilled)
  }
  
  func testResolvedTransition() {
    let promise = Promise<()>(fulfill: ())
    XCTAssertTrue(promise.isFulfilled)
    promise.reject(with: NSError.err)
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
      promise.reject(with: NSError.err, on: nil)
      promise.reject(with: NSError.err, on: nil)
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
    
    promise = Promise(reject: NSError.err)
    promise.catch { _ in ex3.fulfill() }
    promise.finally { _ in ex4.fulfill() }
    
    wait(for: [ex1, ex2, ex3, ex4], timeout: 1)
  }
  
  func testChainResolvedOnMainThread() {
    let ex1 = expectation(description: "")
    let ex2 = expectation(description: "")
    async(0)
      .flatMap(on: .main) { async($0, on: .main) }
      .then { _ in
        XCTAssertTrue(Thread.isMainThread)
        ex1.fulfill()
      }
    async(NSError.err, Int.self)
      .flatMap(on: .main) { async($0, on: .main) }
      .catch { _ in
        XCTAssertTrue(Thread.isMainThread)
        ex2.fulfill()
      }
    wait(for: [ex1, ex2], timeout: 1)
  }
  
  func testAllResolvedOnMainThread() {
    let ex1 = expectation(description: "")
    let ex2 = expectation(description: "")
    all(on: .main, promises: [async(0, on: .main), async(1, on: .main)])
      .then { _ in
        XCTAssertTrue(Thread.isMainThread)
        ex1.fulfill()
      }
    all(on: .main, promises: [async(0, on: .main), async(NSError.err, Int.self, on: .main)])
      .catch { _ in
        XCTAssertTrue(Thread.isMainThread)
        ex2.fulfill()
      }
    waitForExpectations(timeout: 2)
  }
}

extension PromiseTests {
  func testFlatMap() {
    let ex = expectation(description: "")
    async(10)
      .map { $0 + 20 }
      .flatMap(with: async)
      .then {
        XCTAssertEqual(30, $0)
        ex.fulfill()
      }
    waitForExpectations(timeout: 2)
  }
  
  func testFlatMapInfix() {
    let ex = expectation(description: "")
    (async(10) >>- { val in
      async(val + 20)
    }).then {
      XCTAssertEqual(30, $0)
      ex.fulfill()
    }
    waitForExpectations(timeout: 2)
  }
  
  func testFailingFlatMap() {
    let ex1 = expectation(description: "")
    let ex2 = expectation(description: "")
    async(10)
      .flatMap { _ in async(DummyError(), Int.self) }
      .catch {
        XCTAssertTrue($0 is DummyError)
        ex1.fulfill()
      }
    async(DummyError(), Int.self)
      .flatMap(with: async)
      .catch {
        XCTAssertTrue($0 is DummyError)
        ex2.fulfill()
      }
    waitForExpectations(timeout: 2)
  }
  
  func testFlatMapResult() {
    let ex1 = expectation(description: "")
    let ex2 = expectation(description: "")
    async(10)
      .flatMapResult { Result<Int, Error>.success($0 * 2) }
      .then {
        XCTAssertEqual(20, $0)
        ex1.fulfill()
      }
    async(10)
      .flatMapResult { _ in Result<Int, Error>.failure(DummyError()) }
      .catch {
        XCTAssertTrue($0 is DummyError)
        ex2.fulfill()
      }
    waitForExpectations(timeout: 2)
  }
  
  func testMap() {
    let ex = expectation(description: "")
    async(10)
      .map(with: String.init)
      .then {
        XCTAssertEqual("10", $0)
        ex.fulfill()
      }
    waitForExpectations(timeout: 2)
  }
  
  func testMapInfix() {
    let ex = expectation(description: "")
    (async(10) <^> String.init)
      .then {
        XCTAssertEqual("10", $0)
        ex.fulfill()
      }
    waitForExpectations(timeout: 2)
  }
  
  func testMapThrows() {
    let ex = expectation(description: "")
    async(10)
      .map { _ in throw NSError.err }
      .catch { _ in
        ex.fulfill()
      }
    waitForExpectations(timeout: 2)
  }
  
  func testMapError() {
    let ex = expectation(description: "")
    async(NSError.err, Int.self)
      .mapError { _ in DummyError() }
      .catch {
        XCTAssertTrue($0 is DummyError)
        ex.fulfill()
      }
    waitForExpectations(timeout: 2)
  }
  
  func testCompactMap() {
    let ex1 = expectation(description: "")
    let ex2 = expectation(description: "")
    let ex3 = expectation(description: "")
    async("10")
      .compactMap { Int($0) }
      .then {
        XCTAssertEqual(10, $0)
        ex1.fulfill()
      }
    async("a")
      .compactMap { Int($0) }
      .catch { _ in
        ex2.fulfill()
      }
    async("a")
      .compactMap(or: DummyError()) { Int($0) }
      .catch {
        XCTAssertTrue($0 is DummyError)
        ex3.fulfill()
      }
    waitForExpectations(timeout: 2)
  }
  
  func testAlternative() {
    let ex1 = expectation(description: "")
    let ex2 = expectation(description: "")
    (async(1) <|> async(2))
      .then {
        XCTAssertEqual(1, $0)
        ex1.fulfill()
      }
    (async(NSError.err, Int.self) <|> async(2))
      .then {
        XCTAssertEqual(2, $0)
        ex2.fulfill()
      }
    waitForExpectations(timeout: 2)
  }
  
  func testDiscard() {
    let ex1 = expectation(description: "")
    let ex2 = expectation(description: "")
    (async(10) *> async(false))
      .then {
        XCTAssertEqual(false, $0)
        ex1.fulfill()
      }
    (async(10) <* async(false))
      .then {
        XCTAssertEqual(10, $0)
        ex2.fulfill()
      }
    waitForExpectations(timeout: 2)
  }
  
  func testAndPromise() {
    let ex = expectation(description: "")
    async(10).and(async(20))
      .then {
        XCTAssertEqual(10, $0.0)
        XCTAssertEqual(20, $0.1)
        ex.fulfill()
      }
    waitForExpectations(timeout: 2)
  }
  
  func testAnd() {
    let ex = expectation(description: "")
    async(10).and(20)
      .then {
        XCTAssertEqual(10, $0.0)
        XCTAssertEqual(20, $0.1)
        ex.fulfill()
      }
    waitForExpectations(timeout: 2)
  }
  
  func testOr() {
    let ex1 = expectation(description: "")
    let ex2 = expectation(description: "")
    let ex3 = expectation(description: "")
    async(10).or(async(NSError.err, Int.self))
      .then {
        XCTAssertEqual(Either<Int, Int>.left(10), $0)
        ex1.fulfill()
      }
    async(NSError.err, Int.self).or(.value(10))
      .then {
        XCTAssertEqual(Either<Int, Int>.right(10), $0)
        ex2.fulfill()
      }
    async(NSError.err, Int.self).or(async(NSError.err, Int.self))
      .catch { _ in
        ex3.fulfill()
      }
    waitForExpectations(timeout: 2)
  }
  
  func testAllListAsync() {
    let range = (0...5)
    let ex = expectation(description: "")
    ex.expectedFulfillmentCount = range.count
    all(promises: range.map(async))
      .then { values in
        range.forEach {
          XCTAssertEqual($0, values[$0])
          ex.fulfill()
        }
      }
    waitForExpectations(timeout: 2)
  }
  
  func testAllListAsyncFailing() {
    let ex = expectation(description: "")
    all(promises: (0...5).map { _ in async(NSError.err, Int.self) })
      .catch { _ in
        ex.fulfill()
      }
    waitForExpectations(timeout: 2)
  }
  
  func testAllList() {
    let ex = expectation(description: "")
    let promises = (0...5).map(sync)
    all(promises: promises)
      .then { values in
        (0...5).forEach { XCTAssertEqual($0, values[$0]) }
        ex.fulfill()
      }
    waitForExpectations(timeout: 2)
  }
  
  func testAllEmptyList() {
    let ex = expectation(description: "")
    let promises: [Promise<Int>] = []
    all(promises: promises)
      .then { values in
        XCTAssertTrue(values.isEmpty)
        ex.fulfill()
      }
    waitForExpectations(timeout: 2)
  }
  
  func testAllTwo() {
    let ex = expectation(description: "")
    all(
      sync(0),
      async(1),
      async(2)
    ).then { values in
      XCTAssertEqual(values.0, 0)
      XCTAssertEqual(values.1, 1)
      ex.fulfill()
    }
    waitForExpectations(timeout: 2)
  }
  
  func testAllThree() {
    let ex = expectation(description: "")
    all(
      async(0),
      async(1),
      sync(2)
    ).then { values in
      XCTAssertEqual(values.0, 0)
      XCTAssertEqual(values.1, 1)
      XCTAssertEqual(values.2, 2)
      ex.fulfill()
    }
    waitForExpectations(timeout: 2)
  }
  
  func testAllFour() {
    let ex = expectation(description: "")
    all(
      async(0),
      sync(1),
      async(2),
      sync(3)
    ).then { values in
      XCTAssertEqual(values.0, 0)
      XCTAssertEqual(values.1, 1)
      XCTAssertEqual(values.2, 2)
      XCTAssertEqual(values.3, 3)
      ex.fulfill()
    }
    waitForExpectations(timeout: 2)
  }
  
  func testAllFive() {
    let ex = expectation(description: "")
    all(
      async(0),
      sync(1),
      async(2),
      sync(3),
      async(4)
    ).then { values in
      XCTAssertEqual(values.0, 0)
      XCTAssertEqual(values.1, 1)
      XCTAssertEqual(values.2, 2)
      XCTAssertEqual(values.3, 3)
      XCTAssertEqual(values.4, 4)
      ex.fulfill()
    }
    waitForExpectations(timeout: 2)
  }
  
  func testAnyListAsync() {
    let range = (0...5)
    let ex = expectation(description: "")
    ex.expectedFulfillmentCount = range.count
    let promises = (0...5).map(async)
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
    let promises = (0...5).map(sync)
    all(promises: promises)
      .then { values in
        (0...5).forEach { XCTAssertEqual($0, values[$0]) }
        ex.fulfill()
      }
    waitForExpectations(timeout: 2)
  }
  
  func testAnyEmptyList() {
    let ex = expectation(description: "")
    any(promises: [Promise<Int>]())
      .catch { _ in
        ex.fulfill()
      }
    waitForExpectations(timeout: 2)
  }
  
  func testAnyTwo() {
    let ex = expectation(description: "")
    any(
      sync(NSError.err, Int.self),
      async(2)
    ).then { values in
      XCTAssertEqual(values.0, nil)
      XCTAssertEqual(values.1, 2)
      ex.fulfill()
    }
    waitForExpectations(timeout: 2)
  }
  
  func testAnyThree() {
    let ex = expectation(description: "")
    any(
      async(0),
      async(NSError.err, Int.self),
      async(2)
    ).then { values in
      XCTAssertEqual(values.0, 0)
      XCTAssertEqual(values.1, nil)
      XCTAssertEqual(values.2, 2)
      ex.fulfill()
    }
    waitForExpectations(timeout: 2)
  }
  
  func testAnyFour() {
    let ex = expectation(description: "")
    any(
      async(0),
      sync(1),
      async(NSError.err, Int.self),
      sync(3)
    ).then { values in
      XCTAssertEqual(values.0, 0)
      XCTAssertEqual(values.1, 1)
      XCTAssertEqual(values.2, nil)
      XCTAssertEqual(values.3, 3)
      ex.fulfill()
    }
    waitForExpectations(timeout: 2)
  }
  
  func testAnyFive() {
    let ex = expectation(description: "")
    any(
      sync(0),
      async(1),
      sync(2),
      async(NSError.err, Int.self),
      sync(4)
    ).then { values in
      XCTAssertEqual(values.0, 0)
      XCTAssertEqual(values.1, 1)
      XCTAssertEqual(values.2, 2)
      XCTAssertEqual(values.3, nil)
      XCTAssertEqual(values.4, 4)
      ex.fulfill()
    }
    waitForExpectations(timeout: 2)
  }
  
  func testAnyFails() {
    let ex = expectation(description: "")
    any(promises: [
      async(NSError.err, Int.self),
      async(NSError.err, Int.self),
      async(NSError.err, Int.self),
      async(NSError.err, Int.self),
      async(NSError.err, Int.self),
    ]).catch { _ in
      ex.fulfill()
    }
    waitForExpectations(timeout: 2)
  }
  
  func testRaceListAsync() {
    let ex1 = expectation(description: "")
    let ex2 = expectation(description: "")
    let ex3 = expectation(description: "")
    race(promises: (0...5).map { async($0, delay: TimeInterval($0) * 0.1 + 0.05) })
      .then { value in
        XCTAssertEqual(value, 0)
        ex1.fulfill()
      }
    race(promises: (0...5).map { async($0, delay: 0.5 - TimeInterval($0) * 0.1 + 0.05) })
      .then { value in
        XCTAssertEqual(value, 5)
        ex2.fulfill()
      }
    race(promises: (0...5).map { _ in async(NSError.err, Int.self) })
      .catch { _ in
        ex3.fulfill()
      }
    waitForExpectations(timeout: 2)
  }
  
  func testRaceListAsyncFailure() {
    let ex1 = expectation(description: "")
    let promises = (0...5).map {
      $0 > 0
        ? async(10, delay: TimeInterval($0) * 0.1 + 0.05)
        : async(NSError.err, Int.self)
    }
    race(promises: promises)
      .catch { _ in
        ex1.fulfill()
      }
    waitForExpectations(timeout: 2)
  }
  
  func testMapValues() {
    let ex = expectation(description: "")
    async([1, 2, 3])
      .mapValues { $0 * 2 }
      .then {
        XCTAssertEqual($0[0], 2)
        XCTAssertEqual($0[1], 4)
        XCTAssertEqual($0[2], 6)
        ex.fulfill()
      }
    waitForExpectations(timeout: 2)
  }
  
  func testCompactMapValues() {
    let ex = expectation(description: "")
    async(["1", "2", "a", "3"])
      .compactMapValues { Int($0) }
      .then {
        XCTAssertEqual($0[0], 1)
        XCTAssertEqual($0[1], 2)
        XCTAssertEqual($0[2], 3)
        ex.fulfill()
      }
    waitForExpectations(timeout: 2)
  }
  
  func testFlatMapValues() {
    let ex = expectation(description: "")
    async([1, 2, 3])
      .flatMapValues(async)
      .then {
        XCTAssertEqual($0[0], 1)
        XCTAssertEqual($0[1], 2)
        XCTAssertEqual($0[2], 3)
        ex.fulfill()
      }
    waitForExpectations(timeout: 2)
  }
  
  func testFilterValues() {
    let ex = expectation(description: "")
    async([1, 2, 3, 4, 5, 6])
      .filterValues { $0 % 2 == 0 }
      .then {
        XCTAssertEqual($0[0], 2)
        XCTAssertEqual($0[1], 4)
        XCTAssertEqual($0[2], 6)
        ex.fulfill()
      }
    waitForExpectations(timeout: 2)
  }
  
  func testReduceValues() {
    let ex1 = expectation(description: "")
    let ex2 = expectation(description: "")
    let ex3 = expectation(description: "")
    async([1, 2, 3, 4, 5])
      .reduceValues(+)
      .then {
        XCTAssertEqual($0, 15)
        ex1.fulfill()
      }
    async([1, 2, 3, 4, 5])
      .reduceValues(20, +)
      .then {
        XCTAssertEqual($0, 35)
        ex2.fulfill()
      }
    Promise
      .reduce(0, [1, 2, 3, 4, 5].map(async), +)
      .then {
        XCTAssertEqual(15, $0)
        ex3.fulfill()
      }
    waitForExpectations(timeout: 2)
  }
  
  func testSortedValues() {
    let ex = expectation(description: "")
    async([8, 2, 1, 5, 10])
      .sortedValues(by: <)
      .then {
        XCTAssertEqual($0[0], 1)
        XCTAssertEqual($0[1], 2)
        XCTAssertEqual($0[2], 5)
        XCTAssertEqual($0[3], 8)
        XCTAssertEqual($0[4], 10)
        ex.fulfill()
      }
    waitForExpectations(timeout: 2)
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
    waitForExpectations(timeout: 2)
  }
  
  func testUnwrap() {
    let ex1 = expectation(description: "")
    let ex2 = expectation(description: "")
    async(Optional<Int>.some(10))
      .unwrap(or: DummyError())
      .then {
        XCTAssertEqual(10, $0)
        ex1.fulfill()
      }
    async(Optional<Int>.none)
      .unwrap(or: DummyError())
      .catch {
        XCTAssertTrue($0 is DummyError)
        ex2.fulfill()
      }
    waitForExpectations(timeout: 2)
  }
  
  func testFlatMapIf() {
    let ex1 = expectation(description: "")
    let ex2 = expectation(description: "")
    async(true)
      .flatMapIf(
        true: .value(1),
        false: .value(0))
      .then {
        XCTAssertEqual(1, $0)
        ex1.fulfill()
      }
    async(false)
      .flatMapIf(
        true: .value(1),
        false: .value(0))
      .then {
        XCTAssertEqual(0, $0)
        ex2.fulfill()
      }
    waitForExpectations(timeout: 2)
  }
  
  func testMapIf() {
    let ex1 = expectation(description: "")
    let ex2 = expectation(description: "")
    async(true)
      .mapIf(
        true: 1,
        false: 0)
      .then {
        XCTAssertEqual(1, $0)
        ex1.fulfill()
      }
    async(false)
      .mapIf(
        true: 1,
        false: 0)
      .then {
        XCTAssertEqual(0, $0)
        ex2.fulfill()
      }
    waitForExpectations(timeout: 2)
  }
  
  func testFlatMapIf2() {
    let ex1 = expectation(description: "")
    let ex2 = expectation(description: "")
    async(1)
      .flatMapIf(
        transform: { _ in true },
        true: .value(1),
        false: .value(0))
      .then {
        XCTAssertEqual(1, $0)
        ex1.fulfill()
      }
    async(1)
      .flatMapIf(
        transform: { _ in false },
        true: .value(1),
        false: .value(0))
      .then {
        XCTAssertEqual(0, $0)
        ex2.fulfill()
      }
    waitForExpectations(timeout: 2)
  }
  
  func testMapIf2() {
    let ex1 = expectation(description: "")
    let ex2 = expectation(description: "")
    async(1)
      .mapIf(
        transform: { _ in true },
        true: 1,
        false: 0)
      .then {
        XCTAssertEqual(1, $0)
        ex1.fulfill()
      }
    async(1)
      .mapIf(
        transform: { _ in false },
        true: 1,
        false: 0)
      .then {
        XCTAssertEqual(0, $0)
        ex2.fulfill()
      }
    waitForExpectations(timeout: 2)
  }
  
  func testEnsure() {
    let ex1 = expectation(description: "")
    let ex2 = expectation(description: "")
    async(true)
      .ensure { $0 }
      .then { _ in ex1.fulfill() }
    async(false)
      .ensure { $0 }
      .catch { _ in ex2.fulfill() }
    waitForExpectations(timeout: 2)
  }
}

// MARK: - ConcurrentDispatch tests
extension PromiseTests {
  func testConcurrentDispatch1() {
    func next(_ idx: Int) -> Promise<()>? {
      guard idx < 10 else { return nil }
      return async((), delay: .random(in: 0.01...0.5))
    }
    
    let ex = expectation(description: "")
    concurrentlyDispatch(spawnTask: next, concurrent: 1)
      .then { ex.fulfill() }
    waitForExpectations(timeout: 10)
  }
  
  func testConcurrentDispatch2() {
    func next(_ idx: Int) -> Promise<()>? {
      guard idx < 10 else { return nil }
      return async((), delay: .random(in: 0.01...0.5))
    }
    
    let ex = expectation(description: "")
    concurrentlyDispatch(spawnTask: next, concurrent: 5)
      .then { ex.fulfill() }
    waitForExpectations(timeout: 10)
  }
  
  func testConcurrentDispatch3() {
    func next(_ idx: Int) -> Promise<()>? {
      guard idx < 10 else { return nil }
      return async((), delay: .random(in: 0.01...0.5))
    }
    
    let ex = expectation(description: "")
    concurrentlyDispatch(spawnTask: next, concurrent: 100)
      .then { ex.fulfill() }
    waitForExpectations(timeout: 10)
  }
  
  func testConcurrentDispatch4() {
    func next(_ idx: Int) -> Promise<()>? {
      guard idx < 10 else { return nil }
      return async(NSError.err, Void.self, delay: .random(in: 0.01...0.5))
    }
    
    let ex = expectation(description: "")
    concurrentlyDispatch(spawnTask: next, concurrent: 1, retryCount: 0)
      .catch { _ in ex.fulfill() }
    waitForExpectations(timeout: 10)
  }
  
  func testConcurrentDispatch5() {
    var shouldFail = Set<Int>()
    func next(_ idx: Int) -> Promise<()>? {
      guard idx < 10 else { return nil }
      if !shouldFail.contains(idx) {
        shouldFail.insert(idx)
        return async(NSError.err, Void.self, delay: .random(in: 0.01...0.5))
      }
      return async((), delay: .random(in: 0.01...1))
    }
    
    let ex = expectation(description: "")
    concurrentlyDispatch(spawnTask: next, concurrent: 2, retryCount: 1)
      .then { ex.fulfill() }
    waitForExpectations(timeout: 10)
  }
  
  func testConcurrentDispatch6() {
    var shouldFail = [Int: Int]()
    func next(_ idx: Int) -> Promise<()>? {
      guard idx < 10 else { return nil }
      if shouldFail[idx] == nil { shouldFail[idx] = 3 }
      
      if shouldFail[idx]! > 0 {
        shouldFail[idx]! -= 1
        return async(NSError.err, Void.self, delay: .random(in: 0.01...1))
      }
      return async((), delay: .random(in: 0.01...1))
    }
    
    let ex = expectation(description: "")
    concurrentlyDispatch(spawnTask: next, concurrent: 5, retryCount: 2)
      .catch { _ in ex.fulfill() }
    waitForExpectations(timeout: 10)
  }
  
  func testConcurrentDispatch7() {
    var shouldFail = [Int: Int]()
    func next(_ idx: Int) -> Promise<()>? {
      guard idx < 10 else { return nil }
      if shouldFail[idx] == nil { shouldFail[idx] = 3 }
      
      if shouldFail[idx]! > 0 {
        shouldFail[idx]! -= 1
        return async(NSError.err, Void.self, delay: .random(in: 0.01...1))
      }
      return async((), delay: .random(in: 0.01...1))
    }
    
    let ex = expectation(description: "")
    concurrentlyDispatch(spawnTask: next, concurrent: 3, retryCount: 3)
      .then { ex.fulfill() }
    waitForExpectations(timeout: 10)
  }
}

// MARK: - Poll tests
extension PromiseTests {
  func testPollWhile1() {
    var willBeTrueAfter = 5
    func check() -> Promise<Bool> {
      if willBeTrueAfter == 0 {
        return async(true)
      }
      willBeTrueAfter -= 1
      return async(false)
    }
    let ex = expectation(description: "")
    poll(
      repeat: check,
      checkAfter: .milliseconds(100),
      while: { !$0 }
    )
    .then { _ in ex.fulfill() }
    waitForExpectations(timeout: 10)
  }
  
  func testPollWhileFailsDueToRetry() {
    var willBeTrueAfter = 2
    func check() -> Promise<Bool> {
      if willBeTrueAfter == 0 {
        return async(true)
      }
      willBeTrueAfter -= 1
      return async(false)
    }
    let ex = expectation(description: "")
    poll(
      repeat: check,
      checkAfter: .milliseconds(100),
      while: { !$0 },
      maxRetry: 1
    )
    .catch { _ in ex.fulfill() }
    waitForExpectations(timeout: 10)
  }
  
  func testPollWhileFails() {
    let ex1 = expectation(description: "")
    let ex2 = expectation(description: "")
    poll(
      repeat: { async(NSError.err, Bool.self) },
      checkAfter: .milliseconds(100),
      while: { !$0 }
    )
    .catch { _ in ex1.fulfill() }
    poll(
      repeat: { sync(NSError.err, Bool.self) },
      checkAfter: .milliseconds(100),
      while: { !$0 }
    )
    .catch { _ in ex2.fulfill() }
    waitForExpectations(timeout: 10)
  }
  
  func testPollWhileFails2() {
    var willBeTrueAfter = 5
    func check() -> Promise<Bool> {
      if willBeTrueAfter == 0 {
        return async(NSError.err, Bool.self)
      }
      willBeTrueAfter -= 1
      return async(false)
    }
    let ex = expectation(description: "")
    poll(
      repeat: check,
      checkAfter: .milliseconds(100),
      while: { !$0 }
    )
    .catch { _ in ex.fulfill() }
    waitForExpectations(timeout: 10)
  }
}

// MARK: - Sequence tests

extension PromiseTests {
  func testSequence1() {
    func next(_ idx: Int) -> Promise<Int>? {
      guard idx < 10 else { return nil }
      return async(idx, delay: .random(in: 0.01...0.5))
    }
    
    let ex = expectation(description: "")
    sequence(spawnTask: next)
      .then { ex.fulfill() }
    waitForExpectations(timeout: 10)
  }
  
  func testSequence2() {
    var shouldFail = true
    func next(_ idx: Int) -> Promise<Int>? {
      guard idx < 1 else { return nil }
      if shouldFail {
        shouldFail = false
        return async(NSError.err, Int.self, delay: .random(in: 0.01...0.5))
      }
      return async(idx, delay: .random(in: 0.01...0.5))
    }
    
    let ex = expectation(description: "")
    sequence(spawnTask: next, retryCount: 1)
      .then { ex.fulfill() }
    waitForExpectations(timeout: 10)
  }
  
  func testSequence3() {
    func next(_ idx: Int) -> Promise<Int>? {
      async(NSError.err, Int.self, delay: .random(in: 0.01...0.5))
    }
    
    let ex = expectation(description: "")
    sequence(spawnTask: next, retryCount: 1)
      .catch { _ in ex.fulfill() }
    waitForExpectations(timeout: 10)
  }
  
  func testSequence4() {
    let promises = [
      { async(0, delay: .random(in: 0.01...0.5)) },
      { async(1, delay: .random(in: 0.01...0.5)) },
      { async(2, delay: .random(in: 0.01...0.5)) },
      { async(3, delay: .random(in: 0.01...0.5)) },
      { async(4, delay: .random(in: 0.01...0.5)) },
    ]
    let ex = expectation(description: "")
    sequence(promises: promises)
      .then { ex.fulfill() }
    waitForExpectations(timeout: 10)
  }
  
  func testSequence5() {
    let promises = [
      { async(0, delay: .random(in: 0.01...0.5)) },
      { async(1, delay: .random(in: 0.01...0.5)) },
      { async(2, delay: .random(in: 0.01...0.5)) },
      { async(NSError.err, Int.self, delay: .random(in: 0.01...0.5)) },
      { async(4, delay: .random(in: 0.01...0.5)) },
    ]
    let ex = expectation(description: "")
    sequence(promises: promises)
      .catch { _ in ex.fulfill() }
    waitForExpectations(timeout: 10)
  }
}

///

func async<E: Error, T>(
  _ error: E,
  _ type: T.Type,
  delay: TimeInterval = 0.01,
  on: DispatchQueue = .global()
) -> Promise<T> {
  after(.now() + delay, on: on)
    .map(on: on) {
      throw error
    }
}

func async<T>(
  _ val: T,
  delay: TimeInterval = 0.01,
  on: DispatchQueue = .global()
) -> Promise<T> {
  after(.now() + delay, on: on, val)
}

func async<T>(
  _ val: T
) -> Promise<T> {
  async(val, delay: 0.01, on: .global())
}


func sync<T>(_ val: T) -> Promise<T> {
  .value(val)
}

func sync<E: Error, T>(
  _ error: E,
  _ type: T.Type
) -> Promise<T> {
  .error(error)
}

struct DummyError: Error {}

struct Point: Decodable {
  let x: Int
  let y: Int
}

extension NSError {
  static var err: NSError { NSError(domain: "", code: -1, userInfo: nil) }
}
