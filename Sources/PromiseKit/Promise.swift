//
//  Promise.swift
//  PovioKit
//
//  Created by Toni Kocjan on 28/02/2019.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import Foundation

public class Promise<Value>: Future<Value, Error> {
  public override init() {
    super.init()
  }
  
  public init(fulfill value: Value) {
    super.init()
    setResult(.success(value))
  }
  
  public init(reject error: Error) {
    super.init()
    setResult(.failure(error))
  }
  
  public convenience init(_ future: (Promise) -> Void) {
    self.init()
    future(self)
  }
  
  public convenience init(_ future: () throws -> Value) {
    do {
      self.init()
      self.resolve(with: try future())
    } catch {
      self.reject(with: error)
    }
  }
  
  public convenience init<E: Error>(result: Result<Value, E>) {
    self.init()
    switch result {
    case .success(let value):
      self.resolve(with: value)
    case .failure(let error):
      self.reject(with: error)
    }
  }
  
  public static func value(_ value: Value) -> Promise<Value> {
    .init(fulfill: value)
  }
  
  public static func error(_ error: Error) -> Promise<Value> {
    .init(reject: error)
  }
  
  public func resolve(with value: Value, on dispatchQueue: DispatchQueue? = .main) {
    setResult(.success(value), on: dispatchQueue)
  }
  
  public func reject(with error: Error, on dispatchQueue: DispatchQueue? = .main) {
    setResult(.failure(error), on: dispatchQueue)
  }
  
  public func resolve(with result: Result<Value, Error>) {
    switch result {
    case .success(let value):
      resolve(with: value)
    case .failure(let error):
      reject(with: error)
    }
  }
  
  public func observe(promise other: Promise) {
    other.then { self.resolve(with: $0) }
    other.catch { self.reject(with: $0) }
  }
  
  public func finally(_ completion: @escaping (Value?, Error?) -> Void) {
    finally {
      switch $0 {
      case .success(let result):
        completion(result, nil)
      case .failure(let error):
        completion(nil, error)
      }
    }
  }
  
  func finally(_ success: @escaping (Value) -> Void, _ failure: @escaping (Error) -> Void) {
    finally {
      switch $0 {
      case .success(let result):
        success(result)
      case .failure(let error):
        failure(error)
      }
    }
  }
  
  public func cascade(to promise: Promise, on dispatchQueue: DispatchQueue? = .main) {
    self.then { promise.resolve(with: $0, on: dispatchQueue) }
    self.catch { promise.reject(with: $0, on: dispatchQueue) }
  }
}

// MARK: - States
public extension Promise {
  var isResolved: Bool {
    result != nil
  }
  
  var isAwaiting: Bool {
    result == nil
  }
  
  var isFulfilled: Bool {
    switch result {
    case .success?:
      return true
    case _:
      return false
    }
  }
  
  var isRejected: Bool {
    switch result {
    case .failure?:
      return true
    case _:
      return false
    }
  }
  
  var value: Value? {
    switch result {
    case .success(let value)?:
      return value
    case _:
      return nil
    }
  }
  
  var error: Error? {
    switch result {
    case .failure(let error)?:
      return error
    case _:
      return nil
    }
  }
}

// MARK: - Utils
public extension Promise {
  /// Convert this Promise to a new Promise where `Value` == ()
  var asVoid: Promise<()> {
    map { _ in }
  }
  
  /// Tap into the promise to produce side-effects.
  func tap(_ work: @escaping (Value) -> Void) -> Self {
    then(work)
    return self
  }
  
  /// Tap into the promise to produce side-effects.
  func tapResult(_ work: @escaping (Result<Value, Error>) -> Void) -> Self {
    finally { work($0) }
    return self
  }
  
  /// Tap into the promise to produce side-effects.
  func tapError(_ work: @escaping (Error) -> Void) -> Self {
    `catch`(work)
    return self
  }
  
  /// Sleep promise execution for given `duration` interval and return new promise with existing value.
  func sleep(
    duration: DispatchTimeInterval,
    on dispatchQueue: DispatchQueue = .main
  ) -> Promise<Value> {
    Promise { seal in
      self.finally {
        switch $0 {
        case .success(let value):
          dispatchQueue.asyncAfter(deadline: .now() + duration) {
            seal.resolve(with: value, on: dispatchQueue)
          }
        case .failure(let error):
          dispatchQueue.asyncAfter(deadline: .now() + duration) {
            seal.reject(with: error, on: dispatchQueue)
          }
        }
      }
    }
  }
}

// MARK: - Core
public extension Promise {
  /// Returns a composition of this Promise with the result of calling `transform`.
  ///
  /// Use this method when you want to execute another Promise after this Promise succeeds.
  ///
  /// - Parameter transform: A closure that takes the value of this Promise and
  ///   returns a new Promise transforming the value in some way.
  /// - Returns: A `Promise` which is a composition of two Promises:
  ///   If both promises succeed then their composition succeeds as well.
  ///   If any of the two promises at any point fail, their composition fails as well.
  func flatMap<U>(
    on dispatchQueue: DispatchQueue? = .main,
    with transform: @escaping (Value) throws -> Promise<U>
  ) -> Promise<U> {
    Promise<U> { seal in
      self.finally {
        switch $0 {
        case .success(let value):
          dispatchQueue.async {
            do {
              try transform(value).finally {
                switch $0 {
                case .success(let value):
                  seal.resolve(with: value, on: dispatchQueue)
                case .failure(let error):
                  seal.reject(with: error, on: dispatchQueue)
                }
              }
            } catch {
              seal.reject(with: error, on: dispatchQueue)
            }
          }
        case .failure(let error):
          seal.reject(with: error, on: dispatchQueue)
        }
      }
    }
  }
  
  /// When the current Promise fails (is in error state), run the transformation callback
  /// which may recover from the error by returning a new Promise.
  ///
  /// Use this method when you want to execute another Promise after this Promise fails to
  /// potentially recover from the error.
  ///
  /// - Parameter transform: A closure that takes the error of this Promise and
  ///   returns a new Promise potentially recovering from the error state.
  /// - Returns: A `Promise` that will contain either the value of this promise or the result
  ///   of the recovering promise.
  func flatMapError(
    on dispatchQueue: DispatchQueue? = .main,
    with transform: @escaping (Error) throws -> Promise<Value>
  ) -> Promise<Value> {
    Promise { seal in
      self.finally {
        switch $0 {
        case .success(let value):
          seal.resolve(with: value, on: dispatchQueue)
        case .failure(let error):
          do {
            seal.observe(promise: try transform(error))
          } catch {
            seal.reject(with: error, on: dispatchQueue)
          }
        }
      }
    }
  }
  
  /// When the current Promise is fullfiled, run the transformation callback which returns either
  /// a new value or an error (based on the return Result).
  ///
  /// Use this method for simple data transformation that can result in an error.
  ///
  /// - Parameter transform: A closure that takes the value of this Promise and
  ///   returns a Result transforming the value in some way.
  /// - Returns: A `Promise` containing either the transformed value or an error.
  func flatMapResult<U, E: Error>(
    on dispatchQueue: DispatchQueue? = .main,
    with transform: @escaping (Value) throws -> Result<U, E>
  ) -> Promise<U> {
    map(on: dispatchQueue) {
      switch try transform($0) {
      case .success(let res):
        return res
      case .failure(let error):
        throw error
      }
    }
  }
  
  /// Returns a new Promise, mapping any success value using the given
  /// transformation.
  ///
  /// Use this method when you need to transform the value of a `Promise`
  /// instance when it represents a success.
  ///
  /// - Parameter transform: A closure that takes the success value of this
  ///   instance.
  /// - Returns: A `Promise` with the result of evaluating `transform`
  ///   as the new success value if this instance represents a success.
  func map<U>(
    on dispatchQueue: DispatchQueue? = .main,
    with transform: @escaping (Value) throws -> U
  ) -> Promise<U> {
    flatMap(on: dispatchQueue) {
      do {
        return .value(try transform($0))
      } catch {
        return .error(error)
      }
    }
  }
  
  /// Returns a new Promise, mapping any error value using the given
  /// transformation.
  ///
  /// Use this method when you need to transform the error of a `Promise`
  /// instance when it represents a failure.
  ///
  /// - Parameter transform: A closure that takes the error value of this
  ///   instance.
  /// - Returns: A `Promise` with the result of evaluating `transform`
  ///   as the new error value if this instance represents a failure.
  func mapError(
    on dispatchQueue: DispatchQueue? = .main,
    with transform: @escaping (Error) throws -> Error
  ) -> Promise<Value> {
    flatMapError(on: dispatchQueue) {
      Promise<Value>.error(try transform($0))
    }
  }
  
  /// Returns a new promise, mapping any success value using the given
  /// transformation which returns an optional value.
  ///
  /// Use this method when you need to transform the value of a `Promise`
  /// instance when it represents a success.
  ///
  /// - Parameter transform: A closure that takes the success value of this
  ///   instance and returns an Optional value.
  /// - Returns: A `Promise` with the result of evaluating `transform` if
  ///   it does not return `nil` as the new success value. If it returns `nil`
  ///   then the new Promise fails.
  func compactMap<U>(
    on dispatchQueue: DispatchQueue? = .main,
    or error: @autoclosure @escaping () -> Error = NSError(domain: "com.poviokit.promisekit", code: 100, userInfo: ["description": "`nil` value found after transformation!"]),
    with transform: @escaping (Value) throws -> U?
  ) -> Promise<U> {
    map(on: dispatchQueue) {
      switch try transform($0) {
      case let transformedValue?:
        return transformedValue
      case nil:
        throw error()
      }
    }
  }
  
  /// Returns a new promise that fires only when this promise and
  /// all the provided promises complete. It then provides the result of folding the value of this
  /// promise with the values of all the provided promises.
  ///
  /// - Parameter promises: A list of promises to wait for.
  /// - Parameter with: A function that will be used to fold the values of two promises and return a new value wrapped in a promise.
  /// - Returns: A new promise with the folded value.
  func fold<U>(
    _ promises: [Promise<U>],
    on dispatchQueue: DispatchQueue? = .main,
    with combiningFunction: @escaping (Value, U) -> Promise<Value>
  ) -> Promise<Value> {
    promises.reduce(self) { p1, p2 in
      p1.and(p2).flatMap(on: dispatchQueue, with: combiningFunction)
    }
  }
  
  /// Returns a new promise that fires only when all the provided promises complete.
  /// The new promise contains the result of reducing the `initialResult` with the
  /// values of the provided promises.
  ///
  /// - Parameters:
  ///     - initialResult: An initial result to begin the reduction.
  ///     - promises: An array of promises to wait for.
  ///     - nextPartialResult: The bifunction used to produce partial results.
  /// - Returns: A new promise with the reduced value.
  static func reduce<U>(
    _ initialValue: Value,
    _ promises: [Promise<U>],
    on dispatchQueue: DispatchQueue? = .main,
    _ nextPartialResult: @escaping (Value, U) -> Value
  ) -> Promise<Value> {
    Promise
      .value(initialValue)
      .fold(promises, on: dispatchQueue) { .value(nextPartialResult($0, $1)) }
  }
  
  /// Return a new promise that succeeds when this and another promise both succeed.
  ///
  /// This is equivalent to calling `all(:)`.
  ///
  /// - Parameter other: A second `Promise`.
  /// - Returns: A Promise with the result of given promises. If any of the promises fail
  ///   than the returned Promise fails as well with the first error encountered.
  ///
  func and<U>(
    _ other: Promise<U>,
    on dispatchQueue: DispatchQueue? = .main
  ) -> Promise<(Value, U)> {
    all(on: dispatchQueue, self, other)
  }
  
  /// Return a new promise that contains this and another value.
  ///
  /// - Parameter other: Some other value.
  /// - Returns: A Promise containing a pair of values.
  ///
  func and<U>(
    _ value: U,
    on dispatchQueue: DispatchQueue? = .main
  ) -> Promise<(Value, U)> {
    map(on: dispatchQueue) { ($0, value) }
  }
  
  /// Return a new promise that succeeds if either `self` or another promise both succeeds.
  ///
  /// This is equivalent to calling `any(:)`.
  ///
  /// - Parameter other: A second `Promise`.
  /// - Returns: A Promise containing either the value of `self`, or if `self` fails the
  /// result of the other promise.
  func or<U>(
    _ other: Promise<U>,
    on dispatchQueue: DispatchQueue? = .main
  ) -> Promise<Either<Value, U>> {
    any(on: dispatchQueue, self, other)
      .map { l, r in
        if let l = l { return .left(l) }
        else { return .right(r!) }
      }
  }
  
  /// Return a new promise that contains either value of `self` or the given value.
  ///
  /// - Parameter other: Some other value.
  /// - Returns: A Promise containing a either the value of `self`, or if `self` fails the
  /// given given value.
  ///
  func or<U>(
    _ value: U,
    on dispatchQueue: DispatchQueue? = .main
  ) -> Promise<Either<Value, U>> {
    map(on: dispatchQueue, with: Either.left)
      .flatMapError(on: dispatchQueue) { _ in .value(.right(value)) }
  }
  
  /// Check whether the value passes a given predicate. If it does not,
  /// the promise is rejected with the given error.
  ///
  /// - Parameter predicate: A predicate function.
  /// - Parameter error: Error with which the returning promise is rejected
  /// in case the validation fails.
  /// - Returns: A new promise with the same value if the validation succeeds,
  /// otherwise a rejected promise with the given error.
  func ensure(
    on dispatchQueue: DispatchQueue? = .main,
    predicate: @escaping (Value) -> Bool,
    otherwise error: @autoclosure @escaping () -> Error = NSError(domain: "com.poviokit.promisekit", code: 100, userInfo: ["description": "Validation failed"])
  ) -> Promise<Value> {
    map(on: dispatchQueue) {
      guard predicate($0) else {
        throw error()
      }
      return $0
    }
  }
}

public extension Promise where Value == Bool {
  /// Chain the current promise with either `true` or `false` continuation,
  /// depending on the resulting boolean value.
  ///
  /// Use this method when you want to realize non-determinism.
  ///
  /// Promise.value(true)
  ///   .flatMapIf(true: .value(1), false: .value(0))
  ///
  /// - Parameter dispatchQueue: The dispatch queue on which to notify the result.
  /// - Parameter true: The true branch of non-determinism.
  /// - Parameter false: The false branch of non-determinism.
  func flatMapIf<U>(
    on dispatchQueue: DispatchQueue? = .main,
    `true`: @escaping @autoclosure () -> Promise<U>,
    `false`: @escaping @autoclosure () -> Promise<U>
  ) -> Promise<U> {
    flatMap(on: dispatchQueue) {
      switch $0 {
      case true:
        return `true`()
      case false:
        return `false`()
      }
    }
  }
  
  /// Map the current promise with either `true` or `false` continuation,
  /// depending on the resulting boolean value.
  ///
  /// Use this method when you want to realize non-determinism.
  ///
  /// - Parameter dispatchQueue: The dispatch queue on which to notify the result.
  /// - Parameter true: The true branch of non-determinism.
  /// - Parameter false: The false branch of non-determinism.
  func mapIf<U>(
    on dispatchQueue: DispatchQueue? = .main,
    `true`: @escaping @autoclosure () -> U,
    `false`: @escaping @autoclosure () -> U
  ) -> Promise<U> {
    flatMapIf(
      on: dispatchQueue,
      true: .value(`true`()),
      false: .value(`false`())
    )
  }
}

public extension Promise {
  func flatMapIf<U>(
    on dispatchQueue: DispatchQueue? = .main,
    transform: @escaping (Value) -> Bool,
    `true`: @escaping @autoclosure () -> Promise<U>,
    `false`: @escaping @autoclosure () -> Promise<U>
  ) -> Promise<U> {
    map(on: dispatchQueue, with: transform)
      .flatMapIf(true: `true`(), false: `false`())
  }
  
  func mapIf<U>(
    on dispatchQueue: DispatchQueue? = .main,
    transform: @escaping (Value) -> Bool,
    `true`: @escaping @autoclosure () -> U,
    `false`: @escaping @autoclosure () -> U
  ) -> Promise<U> {
    map(on: dispatchQueue, with: transform)
      .mapIf(true: `true`(), false: `false`())
  }
}

public extension Promise where Value: Sequence {
  /// Returns a new Promise containing the results of mapping the given closure
  /// over the sequence's elements.
  ///
  /// In this example, `mapValues` is used to square every number in the array:
  ///
  ///     Promise<[Int]>.value([1, 2, 3])
  ///       .mapValues { $0 * 2 }
  ///       .onSuccess { /* $0 => [2, 4, 6] */ }
  ///
  /// - Parameter transform: A mapping closure. `transform` accepts an
  ///   element of the sequence as its parameter and returns a transformed
  ///   value of the same or of a different type.
  /// - Returns: A Promise containing an array of the transformed elements of the
  ///   sequence.
  func mapValues<U>(
    on dispatchQueue: DispatchQueue? = .main,
    _ transform: @escaping (Value.Element) throws -> U
  ) -> Promise<[U]> {
    map(on: dispatchQueue) { values in try values.map(transform) }
  }
  
  /// Returns a new Promise containing an array containing the non-`nil` results of calling the given
  /// transformation with each element of this sequence.
  ///
  /// Use this method to receive a Promise containing an array of non-optional values when your
  /// transformation produces an optional value.
  ///
  /// In this example, first `compactMapValues` is used to convert String to Int
  /// and then `mapValues` is used to square every number:
  ///
  ///     Promise<[String]>.value(["1", "2", "not a number", "3"])
  ///       .compactMapValues { Int($0) }
  ///       .mapValues { $0 * 2 }
  ///       .onSuccess { /* $0 => [2, 4, 6] */ }
  ///
  /// - Parameter transform: A closure that accepts an element of the
  ///   sequence as its argument and returns an optional value.
  /// - Returns: A Promise containing an array of the non-`nil` results of calling `transform`
  ///   with each element of the sequence.
  func compactMapValues<U>(
    on dispatchQueue: DispatchQueue? = .main,
    _ transform: @escaping (Value.Element) throws -> U?
  ) -> Promise<[U]> {
    map(on: dispatchQueue) { values in
      try values.compactMap(transform)
    }
  }
  
  /// Returns a new Promise containing the `Combine`d results of mapping the given closure
  /// over the sequence's elements where the closure returns another `Promise`.
  ///
  /// In this example, `flatMapValues` is used to combin three Promises obtained by calling the `fetch`
  /// method:
  ///
  ///     func fetch(by id: String) -> Promise<Model> {
  ///       /* ... */
  ///     }
  ///
  ///     Promise<[String]>.value(["id1", "id2", "id3"])
  ///       .flatMapValues(with: fetch)
  ///       .onSuccess { /* $0 contains results of all three `Promise`s */ }
  ///
  /// - Parameter transform: A mapping closure. `transform` accepts an
  ///   element of the sequence as its parameter and returns a Promise (having the same or different `Value` type)
  /// - Returns: A Promise containing the combined result of all the promises obtained by
  ///   mapping elements of this sequence.
  func flatMapValues<U>(
    on dispatchQueue: DispatchQueue? = .main,
    _ transform: @escaping (Value.Element) throws -> Promise<U>
  ) -> Promise<[U]> {
    flatMap(on: dispatchQueue) { values in
      all(promises: try values.map(transform))
    }
  }
  
  /// Returns a new Promise containing an array with, in order, the elements of the sequence
  /// that satisfy the given predicate.
  ///
  /// In this example, `filterValues` is used to include only even numbers:
  ///
  ///     Promise<[Int]>.value([1, 2, 3, 4, 5, 6])
  ///       .filter { $0 % 2 == 0 }
  ///       .onSuccess { /* $0 => [2, 3, 6] */ }
  ///
  /// - Parameter isIncluded: A closure that takes an element of the
  ///   sequence as its argument and returns a Boolean value indicating
  ///   whether the element should be included in the result.
  /// - Returns: An Promise containing an array of the elements that `isIncluded` allowed.
  func filterValues(
    on dispatchQueue: DispatchQueue? = .main,
    _ isIncluded: @escaping (Value.Element) throws -> Bool
  ) -> Promise<[Value.Element]> {
    map(on: dispatchQueue) { values in
      try values.filter(isIncluded)
    }
  }
  
  /// Returns a new Promise combining the elements of the sequence using the
  /// given closure.
  ///
  /// Use the `reduceValues` method to produce a single value from the elements
  /// of the entire sequence. For example, you can use this method to find the sum
  /// or product of the seqeuence:
  ///
  ///     Promise<[Int]>.value([1, 2, 3, 4, 5, 6])
  ///       .reduceValues(0, +)
  ///       .onSuccess { /* $0 => 22 */ }
  ///
  /// - Parameters:
  ///   - initialResult: The value to use as the initial accumulating value.
  ///     `initialResult` is passed to `nextPartialResult` the first time the
  ///     closure is executed.
  ///   - nextPartialResult: A closure that combines an accumulating value and
  ///     an element of the sequence into a new accumulating value, to be used
  ///     in the next call of the `nextPartialResult` closure or returned to
  ///     the caller.
  /// - Returns: A Promise containing the final accumulated value. If the sequence has no elements,
  ///   the result is `initialResult`.
  func reduceValues<A>(
    on dispatchQueue: DispatchQueue? = .main,
    _ initialResult: A,
    _ nextPartialResult: @escaping (A, Value.Element) throws -> A
  ) -> Promise<A> {
    map(on: dispatchQueue) { values in
      try values.reduce(initialResult, nextPartialResult)
    }
  }
  
  /// Returns a Promise containing the elements of the sequence, sorted using the given `comparator` as
  /// the comparison between elements.
  ///
  /// - Parameter comparator: A predicate that returns `true` if its
  ///   first argument should be ordered before its second argument;
  ///   otherwise, `false`.
  /// - Returns: A Promise containing sorted array of the sequence's elements.
  func sortedValues(
    on dispatchQueue: DispatchQueue? = .main,
    by comparator: @escaping (Value.Element, Value.Element) throws -> Bool
  ) -> Promise<[Value.Element]> {
    map(on: dispatchQueue) { values in
      try values.sorted(by: comparator)
    }
  }
}

public extension Promise where Value: Sequence, Value.Element: Sequence {
  /// Returns a new Promise containing the concatenated results of calling the
  /// given transformation with each element of this sequence.
  ///
  /// Use this method to receive a single-level collection when your
  /// transformation produces a sequence or collection for each element.
  ///
  /// In this example, first `flatMapValues` is used to convert flatten the array
  /// and then `mapValues` is used to square every number:
  ///
  ///     Promise<[[Int]]>.value([[1, 2], [3], [4, 5]])
  ///       .flatMapValues { $0 }
  ///       .mapValues { $0 * 2 }
  ///       .onSuccess { /* $0 => [2, 4, 6, 8, 10] */ }
  ///
  /// - Parameter transform: A closure that accepts an element of the
  ///   sequence as its argument and returns a sequence or collection.
  /// - Returns: A Promise containing the resulting flattened array.
  func flatMapValues<U>(
    on dispatchQueue: DispatchQueue? = .main,
    _ transform: @escaping (Value.Element) throws -> [U]
  ) -> Promise<[U]> {
    map(on: dispatchQueue) { values in
      try values.flatMap(transform)
    }
  }
}

public extension Promise where Value: Collection {
  /// Returns a new Promise containing the first element of the collection.
  ///
  /// If the collection is empty, the Promise fails.
  var firstValue: Promise<Value.Element> {
    map { values in
      if let firstValue = values.first {
        return firstValue
      }
      throw NSError()
    }
  }
  
  /// Returns a new Promise containing subsequence with all but the given number of initial
  /// elements.
  ///
  /// - Parameter n: The number of elements to drop from the beginning of
  ///   the collection. `n` must be greater than or equal to zero.
  /// - Returns: A Promise containinng subsequence starting after the specified number of
  ///   elements.
  func dropFirstValues(_ n: Int = 1) -> Promise<Value.SubSequence> {
    map { values in
      values.dropFirst(n)
    }
  }
  
  /// Returns a new Promise containing subsequence with all but the given number of final
  /// elements.
  ///
  /// - Parameter n: The number of elements to drop from the end of
  ///   the collection. `n` must be greater than or equal to zero.
  /// - Returns: A Promise containinng subsequence that leaves off the specified
  ///   number of elements at the end.
  func dropLastValues(_ n: Int = 1) -> Promise<Value.SubSequence> {
    map { values in
      values.dropLast(n)
    }
  }
}

public extension Promise where Value: BidirectionalCollection {
  /// Returns a new Promise containing the last element of the collection.
  ///
  /// If the collection is empty, the Promise fails.
  var lastValue: Promise<Value.Element> {
    map { values in
      if let lastValue = values.last {
        return lastValue
      }
      throw NSError()
    }
  }
}

public extension Promise where Value: Collection, Value.Element: Comparable {
  /// Returns a new Promise containing the minimum element of the collection.
  ///
  /// If the collection is empty, the Promise fails.
  var min: Promise<Value.Element> {
    map { values in
      if let min = values.min() {
        return min
      }
      throw NSError()
    }
  }
  
  /// Returns a new Promise containing the minimum element of the collection.
  ///
  /// If the collection is empty, the Promise fails.
  var max: Promise<Value.Element> {
    map { values in
      if let min = values.max() {
        return min
      }
      throw NSError()
    }
  }
}

public extension Promise where Value == Data {
  /// Returns a new Promise containing a decoded value.
  func decode<D: Decodable>(
    type: D.Type,
    decoder: JSONDecoder,
    on dispatchQueue: DispatchQueue? = .main
  ) -> Promise<D> {
    map(on: dispatchQueue) {
      try decoder.decode(type, from: $0)
    }
  }
}

public extension Promise where Value: Sequence, Value.Element == Int {
  func reduceValues(
    on dispatchQueue: DispatchQueue? = .main,
    _ nextPartialResult: @escaping (Value.Element, Value.Element) throws -> Value.Element
  ) -> Promise<Value.Element> {
    map(on: dispatchQueue) { values in
      try values.reduce(0, nextPartialResult)
    }
  }
}

public extension Promise where Value: Sequence, Value.Element == Double {
  func reduceValues(
    on dispatchQueue: DispatchQueue? = .main,
    _ nextPartialResult: @escaping (Value.Element, Value.Element) throws -> Value.Element
  ) -> Promise<Value.Element> {
    map(on: dispatchQueue) { values in
      try values.reduce(0, nextPartialResult)
    }
  }
}

public extension Promise where Value: Sequence, Value.Element == Float {
  func reduceValues(
    on dispatchQueue: DispatchQueue? = .main,
    _ nextPartialResult: @escaping (Value.Element, Value.Element) throws -> Value.Element
  ) -> Promise<Value.Element> {
    map(on: dispatchQueue) { values in
      try values.reduce(0, nextPartialResult)
    }
  }
}

public extension Promise where Value: Sequence, Value.Element == String {
  func reduceValues(
    on dispatchQueue: DispatchQueue? = .main,
    _ nextPartialResult: @escaping (Value.Element, Value.Element) throws -> Value.Element
  ) -> Promise<Value.Element> {
    map(on: dispatchQueue) { values in
      try values.reduce("", nextPartialResult)
    }
  }
}

public extension Promise where Value: OptionalType {
  func unwrap(or error: @autoclosure @escaping () -> Error) -> Promise<Value.WrappedType> {
    map {
      guard let wrapped = $0.wrapped else {
        throw error()
      }
      return wrapped
    }
  }
}

@available(macOS 10.15, *)
public extension Promise {
  /// Convert promise to async/await
  var asAsync: Value {
    get async throws {
      try await withCheckedThrowingContinuation { cont in  
        finally { 
          switch $0 {
          case .success(let value):
            cont.resume(returning: value)
          case .failure(let error):
            cont.resume(throwing: error)
          }
        }
      }
    }
  }
}

public extension Promise where Value == Void {
  static func value() -> Promise<Value> { value(()) }
  func resolve(on dispatchQueue: DispatchQueue? = .main) { resolve(with: (), on: dispatchQueue) }
}

extension Optional where Wrapped == DispatchQueue {
  @inline(__always)
  func async(execute work: @escaping () -> Void) {
    switch self {
    case let queue?:
      queue.async(execute: work)
    case nil:
      work()
    }
  }
}

/// Taken from `Vapor.Utilities.OptionalTypes`:

/// Capable of being represented by an optional wrapped type.
///
/// This protocol mostly exists to allow constrained extensions on generic
/// types where an associatedtype is an `Optional<T>`.
public protocol OptionalType: AnyOptionalType {
  /// Underlying wrapped type.
  associatedtype WrappedType
  
  /// Returns the wrapped type, if it exists.
  var wrapped: WrappedType? { get }
  
  /// Creates this optional type from an optional wrapped type.
  static func makeOptionalType(_ wrapped: WrappedType?) -> Self
}

/// Conform concrete optional to `OptionalType`.
/// See `OptionalType` for more information.
extension Optional: OptionalType {
  /// See `OptionalType.WrappedType`
  public typealias WrappedType = Wrapped
  
  /// See `OptionalType.wrapped`
  public var wrapped: Wrapped? {
    self
  }
  
  /// See `OptionalType.makeOptionalType`
  public static func makeOptionalType(_ wrapped: Wrapped?) -> Wrapped? {
    wrapped
  }
}

/// Type-erased `OptionalType`
public protocol AnyOptionalType {
  /// Returns the wrapped type, if it exists.
  var anyWrapped: Any? { get }
  
  /// Returns the wrapped type, if it exists.
  static var anyWrappedType: Any.Type { get }
}

extension AnyOptionalType where Self: OptionalType {
  /// See `AnyOptionalType.anyWrapped`
  public var anyWrapped: Any? { wrapped }
  
  /// See `AnyOptionalType.anyWrappedType`
  public static var anyWrappedType: Any.Type { WrappedType.self }
}

//==============================================================================

/// Inspired by `SwiftParsec`:

// Operator definitions.

/// Precedence of infix operator for `Promise.flatMap()`. It has a higher
/// precedence than the `AssignmentPrecedence` group but a lower precedence than
/// the `LogicalDisjunctionPrecedence` group.
precedencegroup FlatMapPrecedence {
  associativity: left
  higherThan: AssignmentPrecedence
  lowerThan: LogicalDisjunctionPrecedence
}

/// Infix operator for `Promise.flatMap()`.
infix operator >>- : FlatMapPrecedence

/// Precedence of infix operator for `Promise.alternative()`. It has a higher
/// precedence than the `FlatMapPrecedence` group.
precedencegroup ChoicePrecedence {
  associativity: left
  higherThan: FlatMapPrecedence
}

/// Infix operator for realising choice.
infix operator <|> : ChoicePrecedence

/// Precedence of infix operators for promise sequencing. It has a higher
/// precedence than the `ChoicePrecedence` group.
precedencegroup SequencePrecedence {
  associativity: left
  higherThan: ChoicePrecedence
}

/// Sequence promises, discarding the value of the first promise.
infix operator *> : SequencePrecedence

/// Sequence promises, discarding the value of the second promise.
infix operator <* : SequencePrecedence

/// Infix operator for `Promise.apply()`.
infix operator <*> : SequencePrecedence

/// Infix operator for `Promise.map()`.
infix operator <^> : SequencePrecedence


/// Infix operator for `Promise.flatMap`.
///
/// Often useful when you want to propagate value(s) down the chain.
///
/// For example:
///
/// f1()
///  .flatMap { f2().and($0) }
///  .flatMap { f3().and($0) }
///  .flatMap { f4($0.1.0) }
///
/// can be written as:
///
/// f1() >>- { v1 in
///   f2() >>- { v2 in
///     f3() >>- { v3 in
///       f4(v1)
///     }
///   }
/// }
public func >>-<T, U>(
  promise: Promise<T>,
  transform: @escaping (T) throws -> Promise<U>
) -> Promise<U> {
  promise.flatMap(on: .main, with: transform)
}

/// This infix operator implements "choice". If `left` fails in tries
/// to "execute" `right`. You can read this operator as "or", i.e.
/// 'left' or 'right'.
///
/// For example:
///
/// Promise.error(.someError) <|> Promise.value(10) >>- { val in
///   // val equals 10
///   ...
/// }
public func <|><T>(
  left: Promise<T>,
  right: @escaping @autoclosure () -> Promise<T>
) -> Promise<T> {
  left.flatMapError(on: .main) { _ in right() }
}

/// This infix operator chains two promises, discarding the value of the first.
///
/// It has the same effect as `left.asVoid.chain { right }`.
public func *><T, U>(
  left: Promise<T>,
  right: Promise<U>
) -> Promise<U> {
  left.asVoid.flatMap(on: .main) { right }
}

/// This infix operator chains two promises, discarding the value of the second.
public func <*<T, U>(
  left: Promise<T>,
  right: Promise<U>
) -> Promise<T> {
  left
    .flatMap(on: .main) { right.and($0) }
    .map(on: .main) { $0.1 }
}

public func <*><T, U>(
  left: Promise<(U) -> T>,
  right: Promise<U>
) -> Promise<T> {
  right >>- { r in
    left.map(on: .main) { $0(r) }
  }
}

/// Infix operator for `Promise.map()`. Use it for same reasons as `>>-`.
public func <^><T, U>(
  promise: Promise<T>,
  transform: @escaping (T) throws -> U
) -> Promise<U> {
  promise.map(on: .main, with: transform)
}
