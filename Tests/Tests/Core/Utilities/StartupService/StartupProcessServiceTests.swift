//
//  StartupProcessServiceTests.swift
//  PovioKit_Tests
//
//  Created by Klemen Zagar on 05/12/2019.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import XCTest
@testable import PovioKit

class StartupProcessServiceTests: XCTestCase {
  func testShouldCompleteProccesWhenCallExecution() {
    let sut = StartupProcessService()
    let mock = MockedStartupService()
    sut.execute(process: mock)
    XCTAssertEqual(mock.completed, true)
  }
}

private class MockedStartupService: StartupProcess {
  var completed: Bool = false
  func run(completion: @escaping (Bool) -> Void) {
    completed = true
    return
  }
}
