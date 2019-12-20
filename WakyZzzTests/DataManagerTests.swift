//
//  DataManagerTests.swift
//  WakyZzzTests
//
//  Created by zsolt on 20/12/2019.
//  Copyright © 2019 Olga Volkova OC. All rights reserved.
//

//import XCTest
//import RealmSwift
//@testable import WakyZzz
//
//class AlarmTest: Object {
//    dynamic var uuid = UUID().uuidString
//}
//
//class DataManagerTests: XCTestCase {
//
//    var realm: Realm!
//    var alarm: AlarmTest!
//    var controller: AlarmsViewController!
//
//    override func setUp() {
//        super.setUp()
//        Realm.Configuration.defaultConfiguration =
//            Realm.Configuration(inMemoryIdentifier: UUID().uuidString)
//
//        alarm = AlarmTest()
//        realm = try! Realm()
//        try! realm.write {
//            realm.add([alarm!])
//        }
//    }
//    override func tearDown() {
//        super.tearDown()
//    }
//    func testSetup() {
//        let alarms = try! Realm().objects(AlarmTest.self)
//        XCTAssertEqual(alarms.count, 1)
//    }
//}
