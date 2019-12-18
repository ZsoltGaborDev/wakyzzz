//
//  Alarm.swift
//  WakyZzz
//
//  Created by Olga Volkova on 2018-05-30.
//  Copyright © 2018 Olga Volkova OC. All rights reserved.
//

import UIKit
import RealmSwift

enum Day: String {
    case Sunday = "Sunday"
    case Monday = "Monday"
    case Tuesday = "Tuesday"
    case Wednesday = "Wednesday"
    case Thursday = "Thursday"
    case Friday = "Friday"
    case Saturday = "Saturday"
    
    func get() -> String {
        switch self {
        case .Sunday:
            return "Sunday"
        case .Monday:
            return "Monday"
        case .Tuesday:
            return "Tuesday"
        case .Wednesday:
            return "Wednesday"
        case .Thursday:
            return "Thursday"
        case .Friday:
            return "Friday"
        case .Saturday:
            return "Saturday"
        }
    }
}

class Alarm: Object {
    @objc dynamic public var date = Date()
    @objc dynamic public private(set) var repeatingDays: String = ""
    public private(set) var days = [Day]()
    @objc dynamic public var enabled = true
    var repeatDays = [false, false, false, false, false, false, false]
    
    public func set(repeating day: Day) {
        if !days.contains(day) {
            days.append(day)
        }
        switch day {
        case .Sunday:
            repeatingDays.append("S")
        case .Monday:
            repeatingDays.append("M")
        case .Tuesday:
            repeatingDays.append("T")
        case .Wednesday:
            repeatingDays.append("W")
        case .Thursday:
            repeatingDays.append("H")
        case .Friday:
            repeatingDays.append("F")
        case .Saturday:
            repeatingDays.append("A")
        }
    }

    public func remove(repeating day: Day) {
        if days.contains(day) {
            days.remove(at: days.firstIndex(of: day)!)
        }
        switch day {
        case .Sunday:
            repeatingDays = repeatingDays.replacingOccurrences(of: "S", with: "")
        case .Monday:
            repeatingDays = repeatingDays.replacingOccurrences(of: "M", with: "")
        case .Tuesday:
            repeatingDays = repeatingDays.replacingOccurrences(of: "T", with: "")
        case .Wednesday:
            repeatingDays = repeatingDays.replacingOccurrences(of: "W", with: "")
        case .Thursday:
            repeatingDays = repeatingDays.replacingOccurrences(of: "H", with: "")
        case .Friday:
            repeatingDays = repeatingDays.replacingOccurrences(of: "F", with: "")
        case .Saturday:
            repeatingDays = repeatingDays.replacingOccurrences(of: "A", with: "")
        }
    }
    
    static let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var caption: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: self.date)
    }
    
    var subCaption: String {
        var captions = [String]()
        for i in 0 ... 6 {
            if repeatDays[i] {
                captions.append(Alarm.daysOfWeek[i])
            }
        }
        return captions.count > 0 ? captions.joined(separator: ", ") : "One time alarm"
    }
    
    public func checkRepeatingDays(alarm: Alarm?, day: Day, mark: Bool) {
        switch day {
        case .Sunday:
            alarm?.repeatDays[0] = mark
        case .Monday:
            alarm?.repeatDays[1] = mark
        case .Tuesday:
            alarm?.repeatDays[2] = mark
        case .Wednesday:
            alarm?.repeatDays[3] = mark
        case .Thursday:
            alarm?.repeatDays[4] = mark
        case .Friday:
            alarm?.repeatDays[5] = mark
        case .Saturday:
            alarm?.repeatDays[6] = mark
        }
    }
    
    public func checkDay(index: Int) -> Day {
        switch index {
        case 0:
            return .Sunday
        case 1:
            return .Monday
        case 2:
            return .Tuesday
        case 3:
            return .Wednesday
        case 4:
            return .Thursday
        case 5:
            return .Friday
        case 6:
            return .Saturday
        default:
            return .Monday
        }
    }
    
    public func loadRepeatingDays(alarm: Alarm) {
        for i in alarm.repeatingDays {
            if i == "S"{
                repeatDays[0] = true
                alarm.days.append(.Sunday)
            } else if i == "M" {
                repeatDays[1] = true
                alarm.days.append(.Monday)
            } else if i == "T" {
                repeatDays[2] = true
                alarm.days.append(.Tuesday)
            } else if i == "W" {
                repeatDays[3] = true
                alarm.days.append(.Wednesday)
            } else if i == "H" {
                repeatDays[4] = true
                alarm.days.append(.Thursday)
            } else if i == "F" {
                repeatDays[5] = true
                alarm.days.append(.Friday)
            } else if i == "A" {
                repeatDays[6] = true
                alarm.days.append(.Saturday)
            }
        }
    }
    
    func setDefaultDate() {
        let date = Date()
        let calendar = Calendar.current
        let h = 8
        let m = 0
        var components = calendar.dateComponents([.hour, .minute, .month, .year, .day, .second, .weekOfMonth,], from: date as Date)
        components.hour = h
        components.minute = m
        self.date = calendar.date(from: components)!
    }
}
