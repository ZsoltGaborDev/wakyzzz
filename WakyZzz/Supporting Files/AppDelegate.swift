//
//  AppDelegate.swift
//  WakyZzz
//
//  Created by Olga Volkova on 2018-05-30.
//  Copyright © 2018 Olga Volkova OC. All rights reserved.
//

import UIKit
import UserNotifications
import MessageUI


protocol SendMessageDelegate {
    func sendEmail()
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let notificationCenter = UNUserNotificationCenter.current()
    var sendMessageDelegate: SendMessageDelegate?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if #available(iOS 13.0, *) {
            self.window?.overrideUserInterfaceStyle = .light
        }
        
        notificationCenter.delegate = self
        
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
            }
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.notification.request.identifier == "SNOOZE_NOTIFICATION" {
            print("Handling notifications with NOOZE_NOTIFICATION Identifier")
            
            if response.actionIdentifier == "Snooze" {
                print("snoozing with MESSAGE_NOTIFICATION ID")
                scheduleNotification(hour: 0, minutes: 0, notificationID: "MESSAGE_NOTIFICATION")
            }
            
            
        } else if response.notification.request.identifier == "MESSAGE_NOTIFICATION" {
            print("Handling notifications with MESSAGE_NOTIFICATION Identifier")
            if  response.actionIdentifier == "Promise" {
                scheduleNotification(hour: 0, minutes: 0, notificationID: "GENERAL")
            } else if response.actionIdentifier == "SendMessage" {
                sendMessageDelegate!.sendEmail()
            }
        }
        
        completionHandler()
    }
    
    func scheduleNotification(hour: Int, minutes: Int, notificationID: String) {
        
        let content = UNMutableNotificationContent()
        let categoryIdentifire = "Alert Notification Type"
        
        
        if notificationID == "MESSAGE_NOTIFICATION" {
            content.title = "Send a kind message!"
            content.body = "Send one kind message now to one of your contacts, or promise to do this later."
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "sound.caf"))
        } else if notificationID == "SNOOZE_NOTIFICATION" {
            content.title = "Late wake up call"
            content.body = "The early bird catches the worm, but the second mouse gets the cheese."
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "sound2.caf"))
        } else if notificationID == "GENERAL"{
            content.title = "Promise Reminder"
            content.body = "Keep your promise and do one Kindness."
            content.sound = UNNotificationSound.default
        }
        
        
        content.badge = 1
        content.categoryIdentifier = categoryIdentifire
        
        let identifier = notificationID
        var trigger: UNNotificationTrigger!
        if identifier == "SNOOZE_NOTIFICATION" {
            let date = Date(timeIntervalSinceNow: 3600)
            var triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
            triggerDate.hour = hour
            triggerDate.minute = minutes
            //trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        } else if identifier == "MESSAGE_NOTIFICATION" || identifier == "GENERAL" {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        }
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        
        let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: [])
        let deleteAction = UNNotificationAction(identifier: "DeleteAction", title: "Delete", options: [.destructive])
        let promiseAction = UNNotificationAction(identifier: "Promise", title: "Promise", options: [])
        let sendMessageAction = UNNotificationAction(identifier: "SendMessage", title: "Send Kind Message", options: [])
        let snoozeCategory = UNNotificationCategory(identifier: categoryIdentifire,
                                              actions: [snoozeAction, deleteAction],
                                              intentIdentifiers: [],
                                              options: [])
        let messageCategory = UNNotificationCategory(identifier: categoryIdentifire,
                                                     actions: [promiseAction, sendMessageAction],
                                                     intentIdentifiers: [],
                                                     options: [])
        let generalCategory = UNNotificationCategory(identifier: categoryIdentifire,
                                                     actions: [deleteAction],
                                                     intentIdentifiers: [],
                                                     options: [])
        if notificationID == "SNOOZE_NOTIFICATION" {
            notificationCenter.setNotificationCategories([snoozeCategory])
        } else if notificationID == "MESSAGE_NOTIFICATION" {
            notificationCenter.setNotificationCategories([messageCategory])
        } else if notificationID == "GENERAL" {
            notificationCenter.setNotificationCategories([generalCategory])
        }
    }
}
