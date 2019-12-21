//
//  AlarmTests.swift
//  WakyZzzTests
//
//  Created by zsolt on 20/12/2019.
//  Copyright © 2019 Olga Volkova OC. All rights reserved.


import XCTest
@testable import WakyZzz

class AlarmTests: XCTestCase {

    var alarm = Alarm()
    var days = [Day(rawValue: "Sunday"), Day(rawValue: "Monday"), Day(rawValue: "Tuesday"), Day(rawValue: "Wednesday"), Day(rawValue: "Thursday"), Day(rawValue: "Friday"), Day(rawValue: "Saturday")]
    var index = 0

   
    func testSetAndRemoveRepeatingDay() {
        let day = days.first!
        alarm.set(repeating: day!)
        XCTAssertEqual(alarm.repeatingDays.first, "S")
        alarm.remove(repeating: day!)
        XCTAssertEqual(alarm.repeatingDays.first, nil)
    }
    func testCheckRepeatingDays() {
        for day in days {
            alarm.checkRepeatingDays(alarm: alarm, day: day!, mark: true)
            XCTAssertEqual(alarm.repeatDays[index], true)
            index += 1
        }
    }
    func testCheckDay() {
        for day in days {
            XCTAssertEqual(alarm.checkDay(index: index), day)
            index += 1
        }
    }
    func testLoadRepeatingDays() {
        if alarm.repeatingDays == "S" {
            alarm.loadRepeatingDays(alarm: alarm)
            XCTAssertEqual(alarm.repeatDays[0], true)
            XCTAssertEqual(alarm.days, [Day.Sunday])
        } else if alarm.repeatingDays == "M" {
            alarm.loadRepeatingDays(alarm: alarm)
            XCTAssertEqual(alarm.repeatDays[1], true)
            XCTAssertEqual(alarm.days, [Day.Monday])
        } else if alarm.repeatingDays == "T" {
            alarm.loadRepeatingDays(alarm: alarm)
            XCTAssertEqual(alarm.repeatDays[2], true)
            XCTAssertEqual(alarm.days, [Day.Tuesday])
        } else if alarm.repeatingDays == "W" {
            alarm.loadRepeatingDays(alarm: alarm)
            XCTAssertEqual(alarm.repeatDays[3], true)
            XCTAssertEqual(alarm.days, [Day.Wednesday])
        } else if alarm.repeatingDays == "H" {
            alarm.loadRepeatingDays(alarm: alarm)
            XCTAssertEqual(alarm.repeatDays[4], true)
            XCTAssertEqual(alarm.days, [Day.Thursday])
        } else if alarm.repeatingDays == "F" {
            alarm.loadRepeatingDays(alarm: alarm)
            XCTAssertEqual(alarm.repeatDays[5], true)
            XCTAssertEqual(alarm.days, [Day.Friday])
        } else if alarm.repeatingDays == "A" {
            alarm.loadRepeatingDays(alarm: alarm)
            XCTAssertEqual(alarm.repeatDays[6], true)
            XCTAssertEqual(alarm.days, [Day.Saturday])
        }
    }
}
