//
//  NotificationCenterDispatcherTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomazin on 20/09/2021.
//  Copyright © 2021 Povio Labs. All rights reserved.
//

import XCTest
@testable import PovioKit

class NotificationCenterDispatcherTests: XCTestCase {
  private let notificationName = Notification.Name("TestNotification")
  private let notificationPayload = ["id": 123]
  
  func testNotificationWithPayload() {
    let promise = expectation(forNotification: notificationName, object: nil, handler: nil)
    NotificationCenterDispatcher.listen(notificationName, observer: self) { notification in
      XCTAssertNotNil(notification.type, "Unknown notification type!")
      guard let payload = notification.userInfo as? [String: Any] else {
        XCTFail("Failed to parse notification payload!")
        return
      }
      XCTAssertEqual(payload["id"] as? Int, 123)
      promise.fulfill()
    }
    
    NotificationCenterDispatcher.post(.custom(name: notificationName), withData: notificationPayload)
    waitForExpectations(timeout: 1)
  }
}
