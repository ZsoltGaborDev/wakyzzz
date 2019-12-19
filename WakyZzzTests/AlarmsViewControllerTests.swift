//
//  WakyZzzTests.swift
//  WakyZzzTests
//
//  Created by zsolt on 18/12/2019.
//  Copyright © 2019 Olga Volkova OC. All rights reserved.
//

import XCTest
@testable import WakyZzz

class AlarmsViewControllerTests: XCTestCase {
    
    var controller: AlarmsViewController!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.controller = (storyboard.instantiateViewController(identifier: "AlarmsViewController") as! AlarmsViewController)
        controller.loadView()
        controller.viewDidLoad()
    }
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTitleIsWakyZzz() {
        XCTAssertEqual("WakyZzz", controller.navigationItem.title)
    }
    func testHasATableView() {
        XCTAssertNotNil(controller.tableView)
    }
    func testTableViewHasDelegate() {
        XCTAssertNotNil(controller.tableView.delegate)
    }
    func testTableViewConfromsToTableViewDelegateProtocol() {
        XCTAssertTrue(controller.conforms(to: UITableViewDelegate.self))
        XCTAssertTrue(controller.responds(to: #selector(controller.tableView(_:editActionsForRowAt:))))
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
        let cell = controller.tableView(controller.tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as? AlarmTableViewCell
        let actualReuseIdentifer = cell?.reuseIdentifier
        let expectedReuseIdentifier = "AlarmCell"
        XCTAssertEqual(actualReuseIdentifer, expectedReuseIdentifier)
    }
    func testTableCellHasCorrectLabelText() {
        
        for i in 0..<controller.sortedAlarms.count {
            let cell = controller.tableView(controller.tableView, cellForRowAt: IndexPath(row: i, section: 0)) as? AlarmTableViewCell
            XCTAssertEqual(cell?.captionLabel.text, controller.sortedAlarms[i].caption)
            XCTAssertEqual(cell?.subcaptionLabel.text, controller.sortedAlarms[i].subCaption)
            XCTAssertEqual(cell?.enabledSwitch.isOn, controller.sortedAlarms[i].enabled)
        }
    }

}
