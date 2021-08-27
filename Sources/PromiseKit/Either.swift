//
//  File.swift
//  PovioKit
//
//  Created by Toni Kocjan on 26/08/2021.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import Foundation

public enum Either<L, R> {
  case left(L)
  case right(R)
}

public extension Either {
  func mapLeft<U>(_ transform: (L) -> U) -> Either<U, R> {
    switch self {
    case .left(let value):
      return .left(transform(value))
    case .right(let value):
      return .right(value)
    }
  }
  
  func mapRight<U>(_ transform: (R) -> U) -> Either<L, U> {
    switch self {
    case .left(let value):
      return .left(value)
    case .right(let value):
      return .right(transform(value))
    }
  }
  
  func flatMapLeft<U>(_ transform: (L) -> Either<U, R>) -> Either<U, R> {
    switch self {
    case .left(let value):
      return transform(value)
    case .right(let value):
      return .right(value)
    }
  }
  
  func flatMapRight<U>(_ transform: (R) -> Either<L, U>) -> Either<L, U> {
    switch self {
    case .left(let value):
      return .left(value)
    case .right(let value):
      return transform(value)
    }
  }
  
  func flatMap<U, K>(
    _ left: (L) -> Either<U, K>,
    _ right: (R) -> Either<U, K>
  ) -> Either<U, K> {
    switch self {
    case .left(let value):
      return left(value)
    case .right(let value):
      return right(value)
    }
  }
  
  var left: L? {
    switch self {
    case .left(let value):
      return value
    case .right:
      return nil
    }
  }
  
  var right: R? {
    switch self {
    case .left:
      return nil
    case .right(let value):
      return value
    }
  }
  
  var isLeft: Bool {
    switch self {
    case .left:
      return true
    case .right:
      return false
    }
  }
  
  var isRight: Bool {
    switch self {
    case .left:
      return false
    case .right:
      return true
    }
  }
}

extension Either: Equatable where L: Equatable, R: Equatable {}
extension Either: Hashable where L: Hashable, R: Hashable {}

public extension Either where R: Error {
  var result: Result<L, R> {
    switch self {
    case .left(let value):
      return .success(value)
    case .right(let error):
      return .failure(error)
    }
  }
}
