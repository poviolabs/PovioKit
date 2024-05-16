//
//  Wrap.swift
//  PovioKit
//
//  Created by Toni Kocjan on 21/07/2020.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import Foundation

public func wrap(on dispatchQueue: DispatchQueue = .main, _ f: (@escaping () -> Void) -> Void) -> Promise<()> {
  Promise { seal in
    f { seal.resolve(on: dispatchQueue) }
  }
}

public func wrap<A, E: Error>(on dispatchQueue: DispatchQueue = .main, _ f: (@escaping (Result<A, E>) -> Void) -> Void) -> Promise<A> {
  Promise { seal in
    f {
      switch $0 {
      case .success(let res):
        seal.resolve(with: res, on: dispatchQueue)
      case .failure(let error):
        seal.reject(with: error, on: dispatchQueue)
      }
    }
  }
}

public func wrap<A, E: Error>(on dispatchQueue: DispatchQueue = .main, _ f: (@escaping (A?, E?) -> Void) -> Void) -> Promise<A> {
  Promise { seal in
    f {
      switch ($0, $1) {
      case (let a?, nil):
        seal.resolve(with: a, on: dispatchQueue)
      case (nil, let error?):
        seal.reject(with: error, on: dispatchQueue)
      case _:
        fatalError()
      }
    }
  }
}

public func wrap<A, E: Error>(on dispatchQueue: DispatchQueue = .main, _ f: (@escaping (A) -> Void) -> Void, _ g: (@escaping (E) -> Void) -> Void) -> Promise<A> {
  Promise { seal in
    f { seal.resolve(with: $0, on: dispatchQueue) }
    g { seal.reject(with: $0, on: dispatchQueue) }
  }
}

public func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
  { a in
    { b in
      f(a, b)
    }
  }
}

public func curry<A, B, C>(_ f: @escaping (A, B) -> C, _ a: A) -> (B) -> C {
  { b in
    f(a, b)
  }
}

public func curry<A, B, C, D>(_ f: @escaping (A, B, C) -> D) -> (A) -> (B) -> (C) -> D  {
  { a in
    { b in
      { c in
        f(a, b, c)
      }
    }
  }
}

public func curry<A, B, C, D>(_ f: @escaping (A, B, C) -> D, _ a: A, _ b: B) -> (C) -> D {
  { c in
    f(a, b, c)
  }
}

public func curry<A, B, C, D, E>(_ f: @escaping (A, B, C, D) -> E) -> (A) -> (B) -> (C) -> (D) -> E {
  { a in
    { b in
      { c in
        { d in
          f(a, b, c, d)
        }
      }
    }
  }
}

public func curry<A, B, C, D, E>(_ f: @escaping (A, B, C, D) -> E, _ a: A, _ b: B, _ c: C) -> (D) -> E {
  { d in
    f(a, b, c, d)
  }
}

public func curry<A, B, C, D, E, F>(_ f: @escaping (A, B, C, D, E) -> F) -> (A) -> (B) -> (C) -> (D) -> (E) -> F {
  { a in
    { b in
      { c in
        { d in
          { e in
            f(a, b, c, d, e)
          }
        }
      }
    }
  }
}

public func curry<A, B, C, D, E, F>(_ f: @escaping (A, B, C, D, E) -> F, _ a: A, _ b: B, _ c: C, _ d: D) -> (E) -> F {
  { e in
    f(a, b, c, d, e)
  }
}

public func curry<A, B, C, D, E, F, G>(_ h: @escaping (A, B, C, D, E, F) -> G) -> (A) -> (B) -> (C) -> (D) -> (E) -> (F) -> G {
  { a in
    { b in
      { c in
        { d in
          { e in
            { f in
              h(a, b, c, d, e, f)
            }
          }
        }
      }
    }
  }
}

public func curry<A, B, C, D, E, F, G>(_ h: @escaping (A, B, C, D, E, F) -> G, _ a: A, _ b: B, _ c: C, _ d: D, _ e: E) -> (F) -> G {
  { f in
    h(a, b, c, d, e, f)
  }
}
