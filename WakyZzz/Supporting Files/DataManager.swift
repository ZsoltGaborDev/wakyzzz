//
//  DataManager.swift
//  WakyZzz
//
//  Created by zsolt on 09/12/2019.
//  Copyright © 2019 Olga Volkova OC. All rights reserved.
//

import Foundation
import RealmSwift

class DataManager {
    
    static let realm = try! Realm()
    
    
    static func saveData(alarm: Alarm) {
        try! realm.write {
            realm.add(alarm)
        }
    }
    
    static func deleteData(alarm: Alarm) {
        let results = realm.objects(Alarm.self)
        for result in results {
            if result.alarmDate == alarm.alarmDate {
                try! realm.write {
                    realm.delete(alarm)
                }
            }
        }
    }
}
