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

protocol DisactivateAlarmDelegate {
    func disableOneTimeAlarm()
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let notificationCenter = UNUserNotificationCenter.current()
    var sendMessageDelegate: SendMessageDelegate?
    var disableAlarmDelegate: DisactivateAlarmDelegate?
    

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
        if response.notification.request.identifier == K.Notifications.snoozeNotificationID {
            if response.actionIdentifier == K.Notifications.snoozeActionID {
                scheduleNotification(hour: 0, minutes: 0, notificationID: K.Notifications.messageNotificationID)
            }
        } else if response.notification.request.identifier == K.Notifications.messageNotificationID {
            if  response.actionIdentifier == K.Notifications.promiseActionID {
                scheduleNotification(hour: 0, minutes: 0, notificationID: K.Notifications.generalNotificationID)
            } else if response.actionIdentifier == K.Notifications.sendMessageActionID {
                sendMessageDelegate!.sendEmail()
            }
        }
        completionHandler()
        center.removeAllDeliveredNotifications()
        disableAlarmDelegate?.disableOneTimeAlarm()
    }
    
    func scheduleNotification(hour: Int, minutes: Int, notificationID: String) {
        
        let content = UNMutableNotificationContent()
        let categoryIdentifire = K.Notifications.categoryID
        if notificationID == K.Notifications.messageNotificationID {
            content.title = K.Notifications.messageNotificationContentTitle
            content.body = K.Notifications.messageNotificationContentBody
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: K.mainAlarmSoundName))
        } else if notificationID == K.Notifications.snoozeNotificationID {
            content.title = K.Notifications.snoozeNotificationContentTitle
            content.body = K.Notifications.snoozeNotificationContentBody
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: K.secondAlarmSoundName))
        } else if notificationID == K.Notifications.generalNotificationID{
            content.title = K.Notifications.promiseNotificationContentTitle
            content.body = K.Notifications.promiseNotificationContentBody
            content.sound = UNNotificationSound.default
        }
        content.badge = 1
        content.categoryIdentifier = categoryIdentifire
        
        let identifier = notificationID
        var trigger: UNNotificationTrigger!
        if identifier == K.Notifications.snoozeNotificationID {
            let date = Date(timeIntervalSinceNow: 3600)
            var triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
            triggerDate.hour = hour
            triggerDate.minute = minutes
            trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        } else if identifier == K.Notifications.messageNotificationID || identifier == K.Notifications.generalNotificationID {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        }
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        
        let snoozeAction = UNNotificationAction(identifier: K.Notifications.snoozeActionID, title: K.Notifications.snoozeActionTitle, options: [])
        let deleteAction = UNNotificationAction(identifier: K.Notifications.deleteActionID, title: K.Notifications.deleteActionTitle, options: [.destructive])
        let okAction = UNNotificationAction(identifier: K.Notifications.okActionID, title: K.Notifications.okActionTitle, options: [.destructive])
        let promiseAction = UNNotificationAction(identifier: K.Notifications.promiseActionID, title: K.Notifications.promiseNotificationContentTitle, options: [])
        let sendMessageAction = UNNotificationAction(identifier: K.Notifications.sendMessageActionID, title: K.Notifications.messageNotificationContentTitle, options: [])
        let snoozeCategory = UNNotificationCategory(identifier: categoryIdentifire,
                                              actions: [snoozeAction, deleteAction],
                                              intentIdentifiers: [],
                                              options: [])
        let messageCategory = UNNotificationCategory(identifier: categoryIdentifire,
                                                     actions: [promiseAction, sendMessageAction],
                                                     intentIdentifiers: [],
                                                     options: [])
        let generalCategory = UNNotificationCategory(identifier: categoryIdentifire,
                                                     actions: [okAction],
                                                     intentIdentifiers: [],
                                                     options: [])
        if notificationID == K.Notifications.snoozeNotificationID {
            notificationCenter.setNotificationCategories([snoozeCategory])
        } else if notificationID == K.Notifications.messageNotificationID {
            notificationCenter.setNotificationCategories([messageCategory])
        } else if notificationID == K.Notifications.generalNotificationID {
            notificationCenter.setNotificationCategories([generalCategory])
        }
    }
}


