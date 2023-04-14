//
//  DomainConvertible.swift
//  
//
//  Created by Toni K. Turk on 23/02/2023.
//

import PovioKitPromise
import Foundation

/// # Domain model transformation:
///
/// A common pattern when dealing with remote APIs is to
/// transform the API response model to an app domain model.
/// 
/// The first approach one might try is to call `map` (or `compactMap`) on
/// the resulting promise:
/// 
///     client
///       .request(method: .get, endpoint: user-endpoint)
///       .validate()
///       .decode(UserResponse.self) // response model `UserResponse`
///       .compactMap { Mapper<User>.map($0) } // domain model `User`
/// 
/// However, the above implementation is suboptimal because the
/// transformation gets executed on the main thread, which can reduce
/// the efficiency of the app.
/// 
/// To solve this, we could give `compactMap` a different queue to execute 
/// the work on: 
/// 
///     ...
///       .compactMap(on: .global()) { Mapper<User>.map($0) }
///       
/// This solves the issue of doing the work on the main thread, but the resulting
/// promise executes its observers on the background queue as well - doing any UI
/// related work, without dispatching to main, would crash the app!
/// 
/// To solve both problems, we provide a small abstraction, which
/// dispatches the transformation work to a background thread, and returns a promise
/// which is resolved on the main thread.
/// 
/// Example:
/// 
///     extension UserResponse: DomainConvertible {
///       func toDomainModel() throws -> User? { ... }
///     }
///     client
///       .request(method: .get, endpoint: user-endpoint)
///       .validate()
///       .decode(UserResponse.self)
///       .mapToDomain()
///       

public protocol DomainConvertible: Decodable {
  associatedtype DomainModel
  func toDomainModel() throws -> DomainModel?
}

public extension Promise where Value: DomainConvertible {
  func mapToDomain<T>(
    transformOn: DispatchQueue = .global(),
    resolveOn: DispatchQueue = .main
  ) -> Promise<T> where T == Value.DomainModel {
    compactMap(on: transformOn) {
      try $0.toDomainModel()
    }
    .map(on: resolveOn) { $0 }
  }
}


public extension Promise where Value: Collection, Value.Element: DomainConvertible {
  func mapToDomain<T>(
    transformOn: DispatchQueue = .global(),
    resolveOn: DispatchQueue = .main
  ) -> Promise<[T]> where T == Value.Element.DomainModel {
    compactMap(on: transformOn) {
      try $0.compactMap { try $0.toDomainModel() }
    }
    .map(on: resolveOn) { $0 }
  }
}
