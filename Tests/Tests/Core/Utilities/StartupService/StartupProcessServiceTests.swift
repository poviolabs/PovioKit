//
//  StartupProcessServiceTests.swift
//  PovioKit_Tests
//
//  Created by Klemen Zagar on 05/12/2019.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitCore
import PovioKitUtilities

class StartupProcessServiceTests: XCTestCase {
  func testShouldCompleteProccesWhenCallExecution() {
    let mock = MockedStartupProcess()
    let mockPersisted = MockedPersistedStartupProcess()
    
    let sut = StartupProcessService()
      .execute(process: mock)
      .execute(process: mockPersisted)

    XCTAssertEqual(MockedStartupProcess.completed, true)
    XCTAssertEqual(MockedPersistedStartupProcess.completed, true)
    
    XCTAssertTrue(sut.persistingProcesses.contains(where: { $0 is MockedPersistedStartupProcess }))
  }
}

private struct MockedStartupProcess: StartupableProcess {
  static var completed = false

  func run() {
    MockedStartupProcess.completed = true
  }
}

private struct MockedPersistedStartupProcess: StartupableProcess, PersistableProcess {
  static var completed = false
  
  func run() {
    MockedPersistedStartupProcess.completed = true
  }
}
