//
//  XCTestCaseTests+Promise.swift
//  PovioKit
//
//  Created by Egzon Arifi on 27/09/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitPromise

class XCTestCaseTests_Promise: XCTestCase {
  func test_awaitPromise_returnsSuccessResultWithExpectedObject() throws {
    let anyObject = anyObject()
    
    switch try awaitPromise(anySuccessPromise(anyObject)) {
    case .success(let object):
      XCTAssertEqual(anyObject, object)
    case .failure:
      XCTFail("Expected success result")
    }
  }
  
  func test_awaitPromise_returnsFailureResultWithExpectedError() throws {
    let anyError = anyNSError()
    
    let failurePromise: Promise<TestDouble> = anyFailurePromise(anyError)
    switch try awaitPromise(failurePromise) {
    case .failure(let error as NSError):
      XCTAssertEqual(anyError as NSError, error)
    case .success:
      XCTFail("Expected failure result")
    }
  }
}

extension XCTestCaseTests_Promise {
  struct TestDouble: Equatable {
    let id: String
  }
  
  func anyObject() -> TestDouble {
    .init(id: UUID().uuidString)
  }
  
  func anyNSError(message: String = "error") -> NSError {
    .init(domain: message, code: -1)
  }
  
  func anySuccessPromise<T>(_ object: T) -> Promise<T> {
    .init(fulfill: object)
  }
  
  func anyFailurePromise<U>(_ error: Error) -> Promise<U> {
    .init(reject: error)
  }
}
