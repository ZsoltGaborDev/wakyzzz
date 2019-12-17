//
//  AlarmViewController.swift
//  WakyZzz
//
//  Created by Olga Volkova on 2018-05-30.
//  Copyright © 2018 Olga Volkova OC. All rights reserved.
//

import Foundation
import UIKit

protocol AlarmViewControllerDelegate {
    func alarmViewControllerDone(alarm: Alarm)
    func alarmViewControllerCancel()
}

class AlarmViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!
    var alarm: Alarm?
    
    var delegate: AlarmViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.datePicker.setValue(false, forKey: "highlightsToday")
        config()
    }
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func config() {        
        if alarm == nil {
            navigationItem.title = "New Alarm"
            alarm = Alarm()
        }
        else {
            navigationItem.title = "Edit Alarm"
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        datePicker.date = alarm!.date
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Alarm.daysOfWeek.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayOfWeekCell", for: indexPath)
        cell.textLabel?.text = Alarm.daysOfWeek[indexPath.row]
        cell.accessoryType = (alarm?.repeatDays[indexPath.row])! ? .checkmark : .none
        if (alarm?.repeatDays[indexPath.row])! {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Repeat on following weekdays"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alarmsToModify = DataManager.realm.objects(Alarm.self).filter({$0.date == self.alarm?.date})
        if let alarmChanged = alarmsToModify.first {
            try! DataManager.realm.write {
                alarmChanged.set(repeating: alarmChanged.checkDay(index: indexPath.row))
                alarmChanged.checkRepeatingDays(alarm: alarmChanged, day: alarmChanged.checkDay(index: indexPath.row), mark: true)
                tableView.cellForRow(at: indexPath)?.accessoryType = (alarmChanged.repeatDays[indexPath.row]) ? .checkmark : .none
            }
        } else {
            alarm?.set(repeating: alarm!.checkDay(index: indexPath.row))
            alarm?.checkRepeatingDays(alarm: alarm, day: alarm!.checkDay(index: indexPath.row), mark: true)
            tableView.cellForRow(at: indexPath)?.accessoryType = (alarm?.repeatDays[indexPath.row])! ? .checkmark : .none
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let alarmsToModify = DataManager.realm.objects(Alarm.self).filter({$0.date == self.alarm?.date})
        if let alarmChanged = alarmsToModify.first {
            try! DataManager.realm.write {
                alarmChanged.remove(repeating: alarmChanged.checkDay(index: indexPath.row))
                alarmChanged.checkRepeatingDays(alarm: alarmChanged, day: alarmChanged.checkDay(index: indexPath.row), mark: false)
                tableView.cellForRow(at: indexPath)?.accessoryType = (alarmChanged.repeatDays[indexPath.row]) ? .checkmark : .none
            }
        } else {
            alarm?.set(repeating: alarm!.checkDay(index: indexPath.row))
            alarm?.checkRepeatingDays(alarm: alarm, day: alarm!.checkDay(index: indexPath.row), mark: false)
            tableView.cellForRow(at: indexPath)?.accessoryType = (alarm?.repeatDays[indexPath.row])! ? .checkmark : .none
        }
    }
    
    @IBAction func cancelButtonPress(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPress(_ sender: Any) {
        delegate?.alarmViewControllerDone(alarm: alarm!)
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func datePickerValueChanged(_ sender: Any) {
        let alarmsToModify = DataManager.realm.objects(Alarm.self).filter({$0.date == self.alarm?.date})
        if let alarmChanged = alarmsToModify.first {
            try! DataManager.realm.write {
                alarmChanged.date = datePicker.date
            }
        } else {
            alarm?.date = datePicker.date
        }
    }
}
