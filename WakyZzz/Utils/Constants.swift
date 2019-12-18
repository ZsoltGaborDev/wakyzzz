//
//  Utils.swift
//  WakyZzz
//
//  Created by zsolt on 18/12/2019.
//  Copyright © 2019 Olga Volkova OC. All rights reserved.
//

import Foundation

struct K {
    static let mainAlarmSoundName = "sound.caf"
    static let secondAlarmSoundName = "sound2.caf"
    
    
    struct Notifications {
        static let snoozeNotificationID = "SNOOZE_NOTIFICATION"
        static let messageNotificationID = "MESSAGE_NOTIFICATION"
        static let generalNotificationID = "GENERAL"
        
        static let categoryID = "Alert Notification Type"
        
        
        static let sendMessageActionID = "SendMessage"
        static let messageNotificationContentTitle = "Send Kind Message!"
        static let messageNotificationContentBody = "Send one kind message now to one of your contacts, or promise to do this later."
        
        static let snoozeActionID = "Snooze"
        static let snoozeActionTitle = "Snooze"
        static let snoozeNotificationContentTitle = "Late wake up call"
        static let snoozeNotificationContentBody = "The early bird catches the worm, but the second mouse gets the cheese."
        
        static let promiseActionID = "Promise"
        static let promiseNotificationContentTitle = "Promise Reminder"
        static let promiseNotificationContentBody = "Keep your promise and do one Kindness."
        
        static let deleteActionID = "DeleteAction"
        static let deleteActionTitle = "Delete"
        
        static let okActionID = "OkAction"
        static let okActionTitle = "OK"
        
    }
}
