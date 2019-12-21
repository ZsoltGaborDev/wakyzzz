//
//  NotificationsTests.swift
//  WakyZzzTests
//
//  Created by zsolt on 20/12/2019.
//  Copyright © 2019 Olga Volkova OC. All rights reserved.
//

import XCTest

protocol UNUserNotificationCenterProtocol: class {
  func add(_ request: UNNotificationRequest,
           withCompletionHandler completionHandler: ((Error?) -> Void)?)
}

class MockNotificationCenter: UNUserNotificationCenterProtocol {

  var addRequestExpectation: XCTestExpectation?

  func add(_ request: UNNotificationRequest,
           withCompletionHandler completionHandler: ((Error?) -> Void)?) {
    addRequestExpectation?.fulfill()
    print("Mock center log")
    completionHandler?(nil)
  }
}

extension UNUserNotificationCenter: UNUserNotificationCenterProtocol {
  func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?) {
    print("Notification center log")
    completionHandler?(nil)
  }
}

class ExampleClass {
  var notificationCenter: UNUserNotificationCenterProtocol = UNUserNotificationCenter.current()

  func doSomething() {
    // Create a request.
    let content = UNNotificationContent()
    let request = UNNotificationRequest(identifier: "Request",
                                           content: content,
                                           trigger: nil)
    notificationCenter.add(request) { (error: Error?) in
    }
  }
}

class NotificationsTests: XCTestCase {
  // Class being tested
  var exampleClass: ExampleClass!
  // Create your mock class.
  var mockNotificationCenter = MockNotificationCenter()

    override func setUp() {
     super.setUp()
     exampleClass = ExampleClass()
     exampleClass.notificationCenter = mockNotificationCenter
  }

  func testDoSomething() {
    mockNotificationCenter.addRequestExpectation = expectation(description: "Add request should've been called")
    exampleClass.doSomething()
    waitForExpectations(timeout: 1)
  }
}
