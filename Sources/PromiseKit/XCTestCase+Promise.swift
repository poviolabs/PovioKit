//
//  XCTestCase+Promise.swift
//  PovioKit
//
//  Created by Egzon Arifi on 27/09/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import XCTest

public extension XCTestCase {
  func awaitPromise<T>(
    _ promise: Promise<T>,
    timeout: TimeInterval = 1,
    file: StaticString = #file,
    line: UInt = #line
  ) throws -> Result<T, Error> {
    let expectation = XCTestExpectation(description: "Wait for promise")
    
    var result: Result<T, Error>?
    
    promise.finally { value, error in
      if let promiseError = error {
        result = .failure(promiseError)
      } else if let value = value {
        result = .success(value)
      }
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: timeout)
    
    let unwrappedResult = try XCTUnwrap(
      result,
      "Awaited promise did not produce any output",
      file: file,
      line: line
    )
    
    return unwrappedResult
  }
}
