//
//  AlarmsViewController.swift
//  WakyZzz
//
//  Created by Olga Volkova on 2018-05-30.
//  Copyright © 2018 Olga Volkova OC. All rights reserved.
//

import UIKit
import RealmSwift
import MessageUI


class AlarmsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AlarmCellDelegate, AlarmViewControllerDelegate, SendMessageDelegate, DisactivateAlarmDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var appDelegate = UIApplication.shared.delegate as? AppDelegate
    var alarms = [Alarm]()
    var sortedAlarms = [Alarm]()
    
    @IBAction func addButtonPress(_ sender: Any) {
        presentAlarmViewController(alarm: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
  //      deleteAll()
        config()
        appDelegate?.sendMessageDelegate = self
        appDelegate?.disableAlarmDelegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        populateAlarms()
        sortAlarms()
    }
    func config() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func deleteAll() {
        let savedAlarms = DataManager.realm.objects(Alarm.self)
        for alarm in savedAlarms {
            try! DataManager.realm.write {
                DataManager.realm.delete(alarm)
            }
        }
    }
    
    func populateAlarms() {
        alarms.removeAll()
        let savedAlarms = DataManager.realm.objects(Alarm.self)
        for alarmToLoad in savedAlarms {
            alarmToLoad.loadRepeatingDays(alarm: alarmToLoad)
            alarms.append(alarmToLoad)
        }
    }
    //MARK: Table View Delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedAlarms.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.alarmCellID, for: indexPath) as! AlarmTableViewCell
        cell.delegate = self
        if let alarm = alarm(at: indexPath) {
            cell.populate(caption: alarm.caption, subcaption: alarm.subCaption, enabled: alarm.enabled)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.deleteAlarm(at: indexPath)
        }
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            self.editAlarm(at: indexPath)
        }
        return [delete, edit]
    }
    
    func alarm(at indexPath: IndexPath) -> Alarm? {
        return indexPath.row < sortedAlarms.count ? sortedAlarms[indexPath.row] : nil
    }
    
    func deleteAlarm(at indexPath: IndexPath) {
        tableView.beginUpdates()
        let alarmToDelete = sortedAlarms[indexPath.row]
        alarms.removeAll(where: { $0.date == sortedAlarms[indexPath.row].date})
        DataManager.deleteData(alarm: alarmToDelete)
        populateAlarms()
        sortAlarms()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    func editAlarm(at indexPath: IndexPath) {
        presentAlarmViewController(alarm: sortedAlarms[indexPath.row])
    }
    
    //MARK: Alarm Management (add, sort, edit, delete)
    func addAlarm(_ alarm: Alarm, at indexPath: IndexPath) {
        tableView.beginUpdates()
        alarms.insert(alarm, at: indexPath.row)
        sortAlarms()
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        DataManager.saveData(alarm: alarm)
    }
    
    func sortAlarms() {
        sortedAlarms.removeAll()
        sortByDate()
        addNotificationToAlarm()
        tableView.reloadData()
    }
    
    func sortByDate() {
        if alarms.count > 1 {
            let now = Date()
            sortedAlarms = alarms.sorted(by: {
                if $0.date > now {
                    if $1.date > now {
                        return $0.date < $1.date
                    } else {
                        return true
                    }
                } else {
                    if $1.date > now {
                        return false
                    } else {
                        return $0.date < $1.date
                    }
                }
            })
        }
        else {
            sortedAlarms = alarms
        }
    }
    
    func disableOneTimeAlarm() {
        if sortedAlarms.first!.subCaption == K.oneTimeAlarmText {
            let results = DataManager.realm.objects(Alarm.self)
            for result in results {
                if result.date == sortedAlarms.first!.date {
                    try! DataManager.realm.write {
                        result.enabled = false
                    }
                }
            }
        }
    }
    
    func getTodayWeekDay()-> String{
          let dateFormatter = DateFormatter()
          dateFormatter.dateFormat = "EEEE"
          let weekDay = dateFormatter.string(from: Date())
          return weekDay
    }
    
    func alarmCell(_ cell: AlarmTableViewCell, enabledChanged enabled: Bool) {
        if let indexPath = tableView.indexPath(for: cell) {
            if let alarm = self.alarm(at: indexPath) {
                let results = DataManager.realm.objects(Alarm.self)
                for result in results {
                    if result.date == alarm.date {
                        try! DataManager.realm.write {
                            result.enabled = enabled
                        }
                    }
                }
            }
        }
    }
    
    func presentAlarmViewController(alarm: Alarm?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let popupViewController = storyboard.instantiateViewController(withIdentifier: "DetailNavigationController") as! UINavigationController
        let alarmViewController = popupViewController.viewControllers[0] as! AlarmViewController
        alarmViewController.alarm = alarm
        alarmViewController.delegate = self
        present(popupViewController, animated: true, completion: nil)
    }
    
    func alarmViewControllerDone(alarm: Alarm) {
        addAlarm(alarm, at: IndexPath(row: alarms.count, section: 0))
        populateAlarms()
        sortAlarms()
    }
    
    //MARK: Creeate, Add Notification
    func addNotificationToAlarm() {
        if sortedAlarms.count > 0 {
            if sortedAlarms.first!.enabled {
                for day in sortedAlarms.first!.days {
                    let alarmDay = day.get()
                    if alarmDay == getTodayWeekDay() {
                        createNotification()
                    }
                }
                if sortedAlarms.first!.subCaption == K.oneTimeAlarmText {
                    createNotification()
                }
            }
        }
    }
    
    func createNotification() {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: sortedAlarms.first!.date)
        let minutes = calendar.component(.minute, from: sortedAlarms.first!.date)
        self.appDelegate?.scheduleNotification(hour: hour, minutes: minutes, notificationID: K.Notifications.snoozeNotificationID)
    }
}

extension AlarmsViewController: MFMessageComposeViewControllerDelegate {
    
    func sendMessage() {
        if MFMessageComposeViewController.canSendText() {
            let messageVC = MFMessageComposeViewController()
            messageVC.body = "You're so handsome!"
            messageVC.recipients = ["3803405055"]
            messageVC.messageComposeDelegate = self
            self.present(messageVC, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result) {
        case .cancelled:
            print("Message was cancelled")
            dismiss(animated: true, completion: nil)
        case .failed:
            print("Message failed")
            dismiss(animated: true, completion: nil)
        case .sent:
            print("Message was sent")
            dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
}

//MARK: Email Handler
extension AlarmsViewController: MFMailComposeViewControllerDelegate {

    func sendEmail() {
        let randomMessages = ["<p>You're so awesome!</p>",
                              "<p>You're so nice!</p>",
                              "<p>You're the best!</p>",
                              "<p>I'm so lucky to be your friend</p>"]
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setSubject(K.kindnessMessageMailSubject)
            mail.setToRecipients(["testmypalinkapp@gmail.com"])
            mail.setMessageBody(randomMessages.randomElement()!, isHTML: true)
            present(mail, animated: true)
        } else {
            print("Error sending email")
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

}
