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
    // Do anything you want here for your tests, fulfill the expectation to pass the test.
    addRequestExpectation?.fulfill()
    print("Mock center log")
    completionHandler?(nil)
  }
}

// Must extend UNUserNotificationCenter to conform to this protocol in order to use it in your class.
extension UNUserNotificationCenter: UNUserNotificationCenterProtocol {
// I'm only adding this implementation to show a log message in this example. In order to use the original implementation, don't add it here.
  func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?) {
    print("Notification center log")
    completionHandler?(nil)
  }
}

/* ExampleClass.swift */

class ExampleClass {

  // Even though the type is UNUserNotificationCenterProtocol, it will take UNUserNotificationCenter type
  // because of the extension above.
  var notificationCenter: UNUserNotificationCenterProtocol = UNUserNotificationCenter.current()

  func doSomething() {
    // Create a request.
    let content = UNNotificationContent()
    let request = UNNotificationRequest(identifier: "Request",
                                           content: content,
                                           trigger: nil)
    notificationCenter.add(request) { (error: Error?) in
      // completion handler code
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
// Once you run the test, the expectation will be called and "Mock Center Log" will be printed
