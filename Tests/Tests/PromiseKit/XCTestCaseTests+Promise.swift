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
    
    let successPromise = anySuccessPromise(anyObject)
    try expect(successPromise, toCompleteWith: .success(anyObject))
  }
  
  func test_awaitPromise_returnsFailureResultWithExpectedError() throws {
    let anyError = anyNSError()
    
    let failurePromise: Promise<TestDouble> = anyFailurePromise(anyError)
    try expect(failurePromise, toCompleteWith: .failure(anyError))
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
  
  func expect<T: Equatable>(_ promise: Promise<T>,
                            toCompleteWith expectedResult: Result<T, Error>,
                            file: StaticString = #file,
                            line: UInt = #line) throws {
    switch try (awaitPromise(promise), expectedResult) {
    case let (.success(success), .success(expectedSuccess)):
      XCTAssertEqual(success, expectedSuccess, "Expected \(expectedSuccess) got \(success) instead", file: file, line: line)
    case let (.failure(error as NSError), .failure(expectedError as NSError)):
      XCTAssertEqual(error, expectedError, "Expected \(expectedError) got \(error) instead", file: file, line: line)
    default:
      XCTFail("Expected \(expectedResult)", file: file, line: line)
    }
  }
}
