//
//  AlarmViewControllerTests.swift
//  WakyZzzTests
//
//  Created by zsolt on 19/12/2019.
//  Copyright © 2019 Olga Volkova OC. All rights reserved.
//

import XCTest
@testable import WakyZzz

class AlarmViewControllerTests: XCTestCase {
    
    var controller: AlarmViewController!

    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.controller = (storyboard.instantiateViewController(withIdentifier: "AlarmViewController") as! AlarmViewController)
        self.controller.loadView()
        self.controller.viewDidLoad()
    }
    override func tearDown() {
        super.tearDown()
    }
    func testTitleIfAlarmIsNil() {
        if controller.alarm != nil {
            XCTAssertEqual("New Alarm", controller.navigationItem.title)
        } else {
            XCTAssertEqual("Edit Alarm", controller.navigationItem.title)
        }
    }
    func testHasATableView() {
        XCTAssertNotNil(controller.tableView)
    }
    func testTableViewHasDelegate() {
        XCTAssertNotNil(controller.tableView.delegate)
    }
    func testTableViewConfromsToTableViewDelegateProtocol() {
        XCTAssertTrue(controller.conforms(to: UITableViewDelegate.self))
        XCTAssertTrue(controller.responds(to: #selector(controller.tableView(_:didSelectRowAt:))))
        XCTAssertTrue(controller.responds(to: #selector(controller.tableView(_:didDeselectRowAt:))))
    }
    func testTableViewHasDataSource() {
        XCTAssertNotNil(controller.tableView.dataSource)
    }
    func testTableViewConformsToTableViewDataSourceProtocol() {
        XCTAssertTrue(controller.conforms(to: UITableViewDataSource.self))
        XCTAssertTrue(controller.responds(to: #selector(controller.numberOfSections(in:))))
        XCTAssertTrue(controller.responds(to: #selector(controller.tableView(_:numberOfRowsInSection:))))
        XCTAssertTrue(controller.responds(to: #selector(controller.tableView(_:cellForRowAt:))))
    }
    func testTableViewCellHasReuseIdentifier() {
        let cell = controller.tableView(controller.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        let actualReuseIdentifer = cell.reuseIdentifier
        let expectedReuseIdentifier = "DayOfWeekCell"
        XCTAssertEqual(actualReuseIdentifer, expectedReuseIdentifier)
    }
    func testTableCellHasCorrectLabelText() {
        for i in 0..<Alarm.daysOfWeek.count {
            let cell = controller.tableView(controller.tableView, cellForRowAt: IndexPath(row: i, section: 0))
            XCTAssertEqual(cell.textLabel!.text, Alarm.daysOfWeek[i])
        }
    }
    func testDismissPresentingViewController() {
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        if var topController = window?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
          }
            XCTAssertTrue(topController != controller)
        }
    }
}
