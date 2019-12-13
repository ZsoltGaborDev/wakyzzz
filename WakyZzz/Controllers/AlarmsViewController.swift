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


class AlarmsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AlarmCellDelegate, AlarmViewControllerDelegate, MFMailComposeViewControllerDelegate, SendMessageDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let notificationIdentifiers = ["SNOOZE_NOTIFICATION", "MESSAGE_NOTIFICATION"]
    var appDelegate = UIApplication.shared.delegate as? AppDelegate
    var alarms = [Alarm]()
    var editingIndexPath: IndexPath?
    var sortedAlarms = [Alarm]()
    
    @IBAction func addButtonPress(_ sender: Any) {
        presentAlarmViewController(alarm: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        appDelegate?.sendMessageDelegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        sortAlarms()
    }
    func config() {
        tableView.delegate = self
        tableView.dataSource = self
        populateAlarms()
    }
    
    func populateAlarms() {
        
        var alarm: Alarm

        // Weekdays 5am
        alarm = Alarm()
        alarm.time = 5 * 3600
        for i in 1 ... 5 {
            alarm.repeatDays[i] = true
        }
        alarms.append(alarm)

        // Weekend 9am
        alarm = Alarm()
        alarm.time = 9 * 3600
        alarm.enabled = false
        alarm.repeatDays[0] = true
        alarm.repeatDays[6] = true
        alarms.append(alarm)
        
        
//        alarms.removeAll()
//        let results = DataManager.realm.objects(Alarm.self)
//                for result in results {
//                    print(result.alarmDate, result.caption, result.hour)
//        //            try! realm.write {
//        //                realm.delete(result)
//        //            }
//                    alarms.append(result)
//                }
//
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedAlarms.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmCell", for: indexPath) as! AlarmTableViewCell
        cell.delegate = self
        if let alarm = alarm(at: indexPath) {
            cell.populate(caption: alarm.caption, subcaption: alarm.repeating, enabled: alarm.enabled)
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
        //let alarmToDelete = sortedAlarms[indexPath.row]
        //DataManager.deleteData(alarm: alarmToDelete)
        sortedAlarms.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    func editAlarm(at indexPath: IndexPath) {
        editingIndexPath = indexPath
        presentAlarmViewController(alarm: alarm(at: indexPath))
    }
    
    func addAlarm(_ alarm: Alarm, at indexPath: IndexPath) {
        tableView.beginUpdates()
        alarms.insert(alarm, at: indexPath.row)
        sortAlarms()
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        //DataManager.saveData(alarm: alarm)
    }
    
    func sortAlarms() {
        sortedAlarms.removeAll()
        if alarms.count > 1 {
            let now = Date()
            sortedAlarms = alarms.sorted(by: {
                if $0.alarmDate! > now {
                    if $1.alarmDate! > now {
                        return $0.alarmDate! < $1.alarmDate!
                    } else {
                        return true
                    }
                } else {
                    if $1.alarmDate! > now {
                        return false
                    } else {
                        return $0.alarmDate! < $1.alarmDate!
                    }
                }
            })
            if sortedAlarms.count > 0 {
                let calendar = Calendar.current
                let hour = calendar.component(.hour, from: (sortedAlarms.first?.alarmDate)!)
                let minutes = calendar.component(.minute, from: (sortedAlarms.first?.alarmDate)!)
                self.appDelegate?.scheduleNotification(hour: hour, minutes: minutes, notificationID: "SNOOZE_NOTIFICATION")
            }
        }
        else {
            sortedAlarms = alarms
        }
        tableView.reloadData()
    }
    func moveAlarm(from originalIndextPath: IndexPath, to targetIndexPath: IndexPath) {
        let alarm = DataManager.shared.alarmList.remove(at: originalIndextPath.row)
        DataManager.shared.alarmList.insert(alarm, at: targetIndexPath.row)
        tableView.reloadData()
    }
    
    func alarmCell(_ cell: AlarmTableViewCell, enabledChanged enabled: Bool) {
        if let indexPath = tableView.indexPath(for: cell) {
            if let alarm = self.alarm(at: indexPath) {
                alarm.enabled = enabled
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
        if let editingIndexPath = editingIndexPath {
            tableView.reloadRows(at: [editingIndexPath], with: .automatic)
        }
        else {
            addAlarm(alarm, at: IndexPath(row: alarms.count, section: 0))
        }
        editingIndexPath = nil
        sortAlarms()
    }
    
    func alarmViewControllerCancel() {
        editingIndexPath = nil
    }
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["zsolt.gabor@hotmail.com"])
            mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)

            present(mail, animated: true)
        } else {
            print("Error sending email")
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

}
