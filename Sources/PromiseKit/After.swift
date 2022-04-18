//
//  After.swift
//  PovioKit
//
//  Created by Toni Kocjan on 03/02/2020.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation

public func after(_ delay: DispatchTime = .now(), on dispatchQueue: DispatchQueue = .main) -> Promise<()> {
  Promise { seal in
    dispatchQueue.asyncAfter(deadline: delay) {
      seal.resolve(on: dispatchQueue)
    }
  }
}

public func after<T>(_ delay: DispatchTime = .now(), on dispatchQueue: DispatchQueue = .main, _ value: @autoclosure @escaping () -> T) -> Promise<T> {
  Promise { seal in
    dispatchQueue.asyncAfter(deadline: delay) {
      seal.resolve(with: value(), on: dispatchQueue)
    }
  }
}

public func after<T>(_ delay: DispatchTime = .now(), on dispatchQueue: DispatchQueue = .main, _ execute: @escaping () -> T) -> Promise<T> {
  Promise { seal in
    dispatchQueue.asyncAfter(deadline: delay) {
      seal.resolve(with: execute(), on: dispatchQueue)
    }
  }
}
