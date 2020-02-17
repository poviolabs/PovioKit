//
//  Promise.swift
//  PovioKit
//
//  Created by Toni Kocjan on 28/02/2019.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import Foundation

public class Promise<Value, Error: Swift.Error>: Future<Value, Error> {
  public override init() {
    super.init()
  }
  
  public init(fulfill value: Value) {
    super.init()
    result = .success(value)
  }
  
  public init(reject error: Error) {
    super.init()
    result = .failure(error)
  }
  
  public convenience init(_ future: (Promise) -> Void) {
    self.init()
    future(self)
  }
  
  public static func value(_ value: Value) -> Promise<Value, Error> {
    Promise<Value, Error>(fulfill: value)
  }
  
  public static func error(_ error: Error) -> Promise<Value, Error> {
    Promise<Value, Error>(reject: error)
  }
  
  public func resolve(with value: Value) {
    guard !isFulfilled else { return }
    result = .success(value)
  }
  
  public func reject(with error: Error) {
    guard !isRejected else { return }
    result = .failure(error)
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
    other.onSuccess(resolve)
    other.onFailure(reject)
  }
}

public extension Promise {
  var isFulfilled: Bool {
    switch result {
    case .success?:
      return true
    case .failure?, .none:
      return false
    }
  }
  
  var isRejected: Bool {
    switch result {
    case .failure?:
      return true
    case .success?, .none:
      return false
    }
  }
  
  var isAwaiting: Bool {
    result == nil
  }
  
  var value: Value? {
    switch result {
    case .success(let value)?:
      return value
    case .failure?, .none:
      return nil
    }
  }
  
  var error: Error? {
    switch result {
    case .failure(let error)?:
      return error
    case .success?, .none:
      return nil
    }
  }
}

public extension Promise {
  /// Convert this Promise to a new Promise where `Value` == ()
  var asVoid: Promise<(), Error> {
    map { _ in () }
  }
}

public extension Promise {
  /// Returns a composition of this Promise with the result of calling `transform`.
  ///
  /// Use this method when you want to execute another Promise after this Promise succeeds.
  ///
  /// - Parameter transform: A closure that takes the value of this Promise and
  ///   returns a new Promise transforming the value in some way.
  /// - Parameter transformError: A closure that takes the error of this Promise and
  ///   returns a new Promise transforming the error in some way.
  /// - Returns: A `Promise` which is a composition of two Promises:
  ///   If both promises succeed then their composition succeeds as well.
  ///   If any of the two promises at any point fail, their composition fails as well.
  func chain<U, ChainedError: Swift.Error>(with transform: @escaping (Value) -> Promise<U, ChainedError>,
                                           transformError: @escaping (ChainedError) -> Error) -> Promise<U, Error> {
    let result = Promise<U, Error>()
    observe {
      switch $0 {
      case .success(let value):
        let promise = transform(value)
        promise.observe { res in
          switch res {
          case .success(let value):
            result.resolve(with: value)
          case .failure(let error):
            result.reject(with: transformError(error))
          }
        }
      case .failure(let error):
        result.reject(with: error)
      }
    }
    return result
  }
  
  /// Returns a composition of this Promise with the result of calling `transform`.
  ///
  /// Use this method when you want to execute another Promise after this Promise succeeds.
  ///
  /// - Parameter transform: A closure that takes the value of this Promise and
  ///   returns a new Promise transforming the value in some way.
  /// - Parameter transformError: A closure that takes the error of this Promise and
  ///   returns a new Promise transforming the error in some way.
  /// - Returns: A `Promise` which is a composition of two Promises:
  ///   If both promises succeed then their composition succeeds as well.
  ///   If any of the two promises at any point fail, their composition fails as well.
  func chain<U>(with transform: @escaping (Value) -> Promise<U, Error>) -> Promise<U, Error> {
    let result = Promise<U, Error>()
    observe {
      switch $0 {
      case .success(let value):
        let promise = transform(value)
        promise.observe { res in
          switch res {
          case .success(let value):
            result.resolve(with: value)
          case .failure(let error):
            result.reject(with: error)
          }
        }
      case .failure(let error):
        result.reject(with: error)
      }
    }
    return result
  }
  
  /// Returns a new promise, mapping any success value using the given
  /// transformation.
  ///
  /// Use this method when you need to transform the value of a `Promise`
  /// instance when it represents a success.
  ///
  /// - Parameter transform: A closure that takes the success value of this
  ///   instance.
  /// - Returns: A `Promise` with the result of evaluating `transform`
  ///   as the new success value if this instance represents a success.
  func map<U>(with transform: @escaping (Value) -> U) -> Promise<U, Error> {
    chain { Promise<U, Error>(fulfill: transform($0)) }
  }
  
  /// Returns a new promise, mapping any failure value using the given
  /// transformation.
  ///
  /// Use this method when you need to transform the value of a `Promise`
  /// instance when it represents a failure.
  ///
  /// - Parameter transform: A closure that takes the failure value of this
  ///   instance.
  /// - Returns: A `Promise` with the result of evaluating `transform`
  ///   as the new failure value if this instance represents a failure.
  func mapError<NewError>(with transform: @escaping (Error) -> NewError) -> Promise<Value, NewError> where NewError: Swift.Error {
    let result = Promise<Value, NewError>()
    observe {
      switch $0 {
      case .success(let value):
        result.resolve(with: value)
      case .failure(let error):
        result.reject(with: transform(error))
      }
    }
    return result
  }
  
  /// Returns a new Promise, combining multiple `Promise`s.
  ///
  /// Use this method when you need to combine the result of several promises of some type `T`.
  ///
  /// - Parameter promises: A list of `Promises` that you want to combine.
  /// - Returns: A Promise with the result of an array of all the values of the combined promises.
  static func combine<S: Sequence>(promises: S) -> Promise<[Value], Error> where S.Element == Promise<Value, Error> {
    return Promise<[Value], Error> { finalPromise in
      let combineQueue = DispatchQueue(label: "combineQueue", attributes: .concurrent)
      for promise in promises {
        promise.observe { result in
          combineQueue.async(flags: .barrier) {
            switch result {
            case .success:
              if promises.allSatisfy({ $0.isFulfilled }) {
                finalPromise.resolve(with: promises.compactMap { $0.value })
              }
            case .failure(let error):
              finalPromise.reject(with: error)
            }
          }
        }
      }
    }
  }
  
  /// Returns a new Promise, combining multiple `Promise`s.
  ///
  /// Use this method when you need to combine the result of several promises of some type `T`.
  ///
  /// - Parameter promises: A list of `Promises` that you want to combine.
  /// - Returns: A Promise with the result of an array of all the values of the combined promises.
  static func combine<T, E: Swift.Error, S: Sequence>(promises: S) -> Promise<[T], E> where S.Element == Promise<T, E> {
    Promise<T, E>.combine(promises: promises)
  }
}

public extension Promise where Value: Sequence {
  /// Returns a new Promise containing the results of mapping the given closure
  /// over the sequence's elements.
  ///
  /// In this example, `mapValues` is used to square every number in the array:
  ///
  /// Promise<[Int], Error>.value([1, 2, 3])
  ///   .mapValues { $0 * 2 }
  ///   .onSuccess { /* $0 => [2, 4, 6] */ }
  ///
  /// - Parameter transform: A mapping closure. `transform` accepts an
  ///   element of the sequence as its parameter and returns a transformed
  ///   value of the same or of a different type.
  /// - Returns: A Promise containing an array of the transformed elements of the
  ///   sequence.
  func mapValues<U>(_ transform: @escaping (Value.Element) -> U) -> Promise<[U], Error> {
    map { values in values.map(transform) }
  }
  
  /// Returns an array containing the non-`nil` results of calling the given
  /// transformation with each element of this sequence.
  ///
  /// Use this method to receive a Promise containing an array of non-optional values when your
  /// transformation produces an optional value.
  ///
  /// In this example, first `compactMapValues` is used to convert String to Int
  /// and then `mapValues` is used to square every number:
  ///
  /// Promise<[String], Error>.value(["1", "2", "not a number", "3"])
  ///   .compactMapValues { Int($0) }
  ///   .mapValues { $0 * 2 }
  ///   .onSuccess { /* $0 => [2, 4, 6] */ }
  ///
  /// - Parameter transform: A closure that accepts an element of the
  ///   sequence as its argument and returns an optional value.
  /// - Returns: A Promise containing an array of the non-`nil` results of calling `transform`
  ///   with each element of the sequence.
  func compactMapValues<U>(_ transform: @escaping (Value.Element) -> U?) -> Promise<[U], Error> {
    map { values in values.compactMap(transform) }
  }
  
  /// Returns a new Promise containing the `Combine`d results of mapping the given closure
  /// over the sequence's elements where the closure returns another `Promise`.
  ///
  /// In this example, `flatMapValues` is used to combin three Promises obtained by calling the `fetch`
  /// method:
  ///
  /// func fetch(by id: String) -> Promise<Model, Error> {
  ///   /* ... */
  /// }
  ///
  /// Promise<[String], Error>.value(["id1", "id2", "id3"])
  ///   .flatMapValues(with: fetch)
  ///   .onSuccess { /* $0 contains results of all three `Promise`s */ }
  ///
  /// - Parameter transform: A mapping closure. `transform` accepts an
  ///   element of the sequence as its parameter and returns a Promise (having the same or different `Value` type)
  /// - Returns: A Promise containing the combined result of all the promises obtained by
  ///   mapping elements of this sequence.
  func flatMapValues<U>(_ transform: @escaping (Value.Element) -> Promise<U, Error>) -> Promise<[U], Error> {
    chain { values in .combine(promises: values.map(transform)) }
  }
  
  /// Returns a new Promise containing an array with, in order, the elements of the sequence
  /// that satisfy the given predicate.
  ///
  /// In this example, `filterValues` is used to include only even numbers:
  ///
  /// Promise<[Int], Error>.value([1, 2, 3, 4, 5, 6])
  ///   .filter { $0 % 2 == 0 }
  ///   .onSuccess { /* $0 => [2, 3, 6] */ }
  ///
  /// - Parameter isIncluded: A closure that takes an element of the
  ///   sequence as its argument and returns a Boolean value indicating
  ///   whether the element should be included in the result.
  /// - Returns: An Promise containing an array of the elements that `isIncluded` allowed.
  func filterValues(_ isIncluded: @escaping (Value.Element) -> Bool) -> Promise<[Value.Element], Error> {
    map { values in values.filter(isIncluded) }
  }
  
  /// Returns a Promise combining the elements of the sequence using the
  /// given closure.
  ///
  /// Use the `reduceValues` method to produce a single value from the elements
  /// of the entire sequence. For example, you can use this method to find the sum
  /// or product of the seqeuence:
  ///
  /// Promise<[Int], Error>.value([1, 2, 3, 4, 5, 6])
  ///   .reduceValues(0, +)
  ///   .onSuccess { /* $0 => 22 */ }
  ///
  /// `reduce` (or `fold`) is the most general of all the basic higher-order methods operating on sequences. For instance,
  /// it can be used to implement `map`:
  ///
  /// Promise<[Int], Error>.value([1, 2, 3])
  ///   .reduceValues([]) { $0 + [$1 * 2] }
  ///   .onSuccess { /* $0 => [2, 4, 6] */ }
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
  func reduceValues<A>(_ initialResult: A, _ nextPartialResult: @escaping (A, Value.Element) -> A) -> Promise<A, Error> {
    map { values in values.reduce(initialResult, nextPartialResult) }
  }
  
  /// Returns a Promise containing the elements of the sequence, sorted using the given `comparator` as
  /// the comparison between elements.
  ///
  /// - Parameter comparator: A predicate that returns `true` if its
  ///   first argument should be ordered before its second argument;
  ///   otherwise, `false`.
  /// - Returns: A Promise containing sorted array of the sequence's elements.
  func sortedValues(on dispatchQueue: DispatchQueue = .main, by comparator: @escaping (Value.Element, Value.Element) -> Bool) -> Promise<[Value.Element], Error> {
    map { values in values.sorted(by: comparator) }
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
  /// Promise<[[Int]], Error>.value([[1, 2], [3], [4, 5]])
  ///   .flatMapValues { $0 }
  ///   .mapValues { $0 * 2 }
  ///   .onSuccess { /* $0 => [2, 4, 6, 8, 10] */ }
  ///
  /// - Parameter transform: A closure that accepts an element of the
  ///   sequence as its argument and returns a sequence or collection.
  /// - Returns: A Promise containing the resulting flattened array.
  func flatMapValues<U>(_ transform: @escaping (Value.Element) -> [U]) -> Promise<[U], Error> {
    map { values in values.flatMap(transform) }
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

public extension Promise where Value: Sequence, Value.Element == Int {
  func reduceValues(_ nextPartialResult: @escaping (Value.Element, Value.Element) -> Value.Element) -> Promise<Value.Element, Error> {
    map { values in values.reduce(0, nextPartialResult) }
  }
}

public extension Promise where Value: Sequence, Value.Element == Double {
  func reduceValues(_ nextPartialResult: @escaping (Value.Element, Value.Element) -> Value.Element) -> Promise<Value.Element, Error> {
    map { values in values.reduce(0, nextPartialResult) }
  }
}

public extension Promise where Value: Sequence, Value.Element == Float {
  func reduceValues(_ nextPartialResult: @escaping (Value.Element, Value.Element) -> Value.Element) -> Promise<Value.Element, Error> {
    map { values in values.reduce(0, nextPartialResult) }
  }
}

public extension Promise where Value: Sequence, Value.Element == String {
  func reduceValues(_ nextPartialResult: @escaping (Value.Element, Value.Element) -> Value.Element) -> Promise<Value.Element, Error> {
    map { values in values.reduce("", nextPartialResult) }
  }
}

public extension Promise where Value == Void {
  func resolve() { resolve(with: ()) }
}
