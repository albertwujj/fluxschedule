//
//  ScheduleTableViewCell.swift
//  Schedule Maker Prototype
//
//  Created by Albert Wu on 11/7/17.
//  Copyright © 2017 Old Friend. All rights reserved.
//

import UIKit
import Foundation
import UserNotifications


class ScheduleTableViewCell: UITableViewCell, AccessoryTextFieldDelegate, UITextFieldDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var tableViewController: ScheduleTableViewController!
    var startOfToday: Date!
    var row: Int!
    var scheduleItem: ScheduleItem! {
        //Have cell display proper TextField content based on ScheduleItem data
        didSet {
            taskNameTF.text = scheduleItem.taskName
            durationTF.text = durationDescription(duration: scheduleItem.duration)
            if let startTime = scheduleItem.startTime {
                startTimeTF.text = timeDescription(durationSinceMidnight: startTime)
                let endTime = startTime + scheduleItem.duration
                endTimeTF.text = timeDescription(durationSinceMidnight: endTime)
            }
            else {
                startTimeTF.text = "XX:XX"
                endTimeTF.text = "XX:XX"
            }
            lockButton.setTitle(scheduleItem.locked ? "🔒" : "🌀", for: .normal)
        }
    }
    
    
    @IBOutlet weak var startTimeTF: AccessoryTextField!
    @IBOutlet weak var endTimeTF: UITextField!
    @IBOutlet weak var taskNameTF: UITextField!
    @IBOutlet weak var durationTF: AccessoryTextField!
    
    @IBOutlet weak var lockButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        startTimeTF.delegate = self
        durationTF.delegate = self
        taskNameTF.delegate = self
        
        //set midnight as a global Date variable
       
        startOfToday = Calendar.current.startOfDay(for: Date())
        let textFields = self.subviews[0].subviews.filter{$0 is UITextField}
        for i in textFields {
            setStyle(textField: (i as! UITextField))
        }
        startTimeTF.accessoryDelegate = self
        durationTF.accessoryDelegate = self
        startTimeTF.addButtons(customString: nil)
        durationTF.addButtons(customString: nil)
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    //AccessoryTextFieldDelegateFunctions
    func textFieldCustomButtonPressed(_ sender: UITextField) {
        if sender === startTimeTF {
            
        }
        else if sender === durationTF {
            
        }
    }
    func textFieldCancelButtonPressed(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    func textFieldDoneButtonPressed(_ sender: UITextField) {
        if sender === startTimeTF {
            let date = (startTimeTF.inputView as! UIDatePicker).date
            //update startTime and endTime based on chosen date
            scheduleItem.startTime = Int(date.timeIntervalSince(startOfToday))
            
            startTimeTF.text = timeDescription(durationSinceMidnight: scheduleItem.startTime!)
            let endTime = scheduleItem.startTime! + scheduleItem.duration
            endTimeTF.text = timeDescription(durationSinceMidnight: endTime)
            
            ScheduleTableViewCell.moveItem(tvc: tableViewController, origRow: row!, newStartTime: scheduleItem.startTime!, insertOption: appDelegate.userSettings.insertOption, textField: sender)
    
        }
        else if sender === durationTF {
            let duration = (durationTF.inputView as! UIDatePicker).countDownDuration
            scheduleItem.duration = Int(duration)
            durationTF.text = durationDescription(duration: scheduleItem.duration)
            if let startTime = scheduleItem.startTime {
                let endTime = startTime + Int(duration)
                endTimeTF.text = timeDescription(durationSinceMidnight: endTime)
                
            }
            tableViewController.update()
        }
        
     
    }
   
    
    //UITextFieldDelegateFunctions
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectAll(nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == taskNameTF {
            scheduleItem.taskName = textField.text ?? ""
        }
        else if textField == durationTF {
            
        }
        else if textField == startTimeTF {
          
        }
        tableViewController.update()
    }
    
    //MARK: Input handling
    @IBAction func startTimeEditing(_ sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.time
        sender.inputView = datePickerView
        
        let date = Date(timeInterval: Double(scheduleItem.startTime ?? 7 * 3600), since: startOfToday)
        datePickerView.setDate(date, animated: true)
        
        //datePickerView.addTarget(self, action: #selector(ScheduleTableViewCell.datePickerValueChangedStartTime), for: UIControlEvents.valueChanged)
 
    }
    @objc func datePickerValueChangedStartTime(sender:UIDatePicker) {
        let date = sender.date
        //update startTime and endTime based on chosen date
        scheduleItem.startTime = Int(date.timeIntervalSince(startOfToday))
        
        startTimeTF.text = timeDescription(durationSinceMidnight: scheduleItem.startTime!)
        let endTime = scheduleItem.startTime! + scheduleItem.duration
        endTimeTF.text = timeDescription(durationSinceMidnight: endTime)
        
        /*
        switch insertOption {
        case .extend:
            fallthrough
        case .shrink:
            
            
        case .split:
            
            var i = row!
            
            swapLoop: while(i >= 0) {
                i -= 1
                if i == -1 || scheduleItem.startTime! > scheduleItems[i].startTime! {
                    break swapLoop
                }
            }
            let prev = scheduleItems[i]
            let diff = prev.startTime! + prev.duration - scheduleItem.startTime!
            prev.duration -= diff
            let splitItem = ScheduleItem(name: prev.taskName, duration: diff, startTime: scheduleItem.startTime + scheduleItem.duration)
            scheduleItems.insert(scheduleItems.remove(at: row), at: i+1)
            scheduleItems.insert(<#T##newElement: ScheduleItem##ScheduleItem#>, at: <#T##Int#>)
        default:
            break
        }
 */
        /*
        var i = row!
        
        swapLoop: while(i >= 0) {
            i -= 1
            if i == -1 || (scheduleItem.startTime! > scheduleItems[i].startTime! || (scheduleItem.startTime! == scheduleItems[i].startTime! && insertOption == .extend)) {
                break swapLoop
            }
        }
        let prev = row > 0 ? scheduleItems[row - 1] : nil
        if i + 1 == row && row > 0 && scheduleItem.startTime! >= prev!.startTime! + prev!.duration  {
            prev!.duration = scheduleItem.startTime! - prev!.startTime!
            
        }
        else {
            var splitItem: ScheduleItem!
            //let curr = scheduleItems[i+1]
            if (i >= 0) {
                let newPrev = scheduleItems[i]
                let diff = newPrev.startTime! + newPrev.duration - scheduleItem.startTime!
                newPrev.duration -= diff
                
                if(insertOption == .split && diff != 0) {
                    splitItem = ScheduleItem(name: newPrev.taskName, duration: diff, startTime: scheduleItem.startTime! + scheduleItem.duration)
                    scheduleItems.insert(splitItem, at: i + 1)
                }
            }
            
            scheduleItems.insert(scheduleItems.remove(at: row + 1), at: i + 1)
            
            
        }
        tableViewController.scheduleItems = scheduleItems
        tableViewController.update()
 */
        //ScheduleTableViewCell.moveItem(tvc: tableViewController, origRow: row!, newStartTime: scheduleItem.startTime!, insertOption: appDelegate.userSettings.insertOption)
    }
    @objc func doneStartTimeEditing(sender: UIBarButtonItem) {
        let date = (startTimeTF.inputView as! UIDatePicker).date
        //update startTime and endTime based on chosen date
        scheduleItem.startTime = Int(date.timeIntervalSince(startOfToday))
        
        startTimeTF.text = timeDescription(durationSinceMidnight: scheduleItem.startTime!)
        let endTime = scheduleItem.startTime! + scheduleItem.duration
        endTimeTF.text = timeDescription(durationSinceMidnight: endTime)
        
       // ScheduleTableViewCell.moveItem(tvc: tableViewController, origRow: row!, newStartTime: scheduleItem.startTime!, insertOption: appDelegate.userSettings.insertOption)
    }

    static func moveItem(tvc: ScheduleTableViewController, origRow: Int, newStartTime: Int, insertOption: InsertOption, textField: UITextField?) {
        textField?.endEditing(true)
        let tableView = tvc.tableView!
        var finalRow = 0
        var scheduleItems = tvc.scheduleItems
        let scheduleItem = scheduleItems[origRow]
        scheduleItem.startTime = newStartTime
        var i = origRow
        let cell = tvc.tableView.cellForRow(at: IndexPath(row: origRow, section: 0)) as! ScheduleTableViewCell
        //find correct previous item
        swapLoop: while(i >= 0) {
            i -= 1
            if i == -1 || (scheduleItem.startTime! > scheduleItems[i].startTime! || (scheduleItem.startTime! == scheduleItems[i].startTime! && insertOption == .extend)) {
                break swapLoop
            }
        }
        //if extending duration, must take "prev prev" item
        if (insertOption == .extend) {
            i -= 1
        }
        
        let prev = origRow > 0 ? scheduleItems[origRow - 1] : nil
        if origRow > 0 && scheduleItem.startTime! >= prev!.startTime! + prev!.duration  {
            prev!.duration = scheduleItem.startTime! - prev!.startTime!
        }
        else {
            var splitItem: ScheduleItem!
            //let curr = scheduleItems[i+1]
            var diff = 0
            var newPrev: ScheduleItem!
            if (i >= 0) {
                newPrev = scheduleItems[i]
                if newPrev.locked == true {
                    let alertController = UIAlertController(title: "Locked event conflict", message: "New start time would cause event \"\(scheduleItem.taskName)\" to conflict with locked event \"\(newPrev.taskName)\".", preferredStyle: UIAlertControllerStyle.alert)
                    
                    let okAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default)
                    {
                        (result : UIAlertAction) -> Void in
                    }
                    alertController.addAction(okAction)
                    tvc.present(alertController, animated: true, completion: nil)
                    return
                }
                diff = newPrev.startTime! + newPrev.duration - scheduleItem.startTime!
                newPrev.duration -= diff
            }
    
            cell.startTimeTF.text = "\(cell.timeDescription(durationSinceMidnight: newStartTime))"
            finalRow = i+1
            
           
            
            scheduleItems.insert(scheduleItems.remove(at: origRow), at: i + 1)
            
            /*
            if(i >= 0 && insertOption == .split && diff != 0) {
                splitItem = ScheduleItem(name: newPrev.taskName, duration: diff, startTime: scheduleItem.startTime! + scheduleItem.duration)
                scheduleItems.insert(splitItem, at: i + 2)
            }
            */
        }
        tvc.scheduleItems = scheduleItems
        
        
        //tableView.moveRow(at: IndexPath(row: origRow, section: 0), to: IndexPath(row: finalRow, section: 0))
        
        tvc.recalculateTimes()
        tvc.quickReloadCellTimes()
        
    }
    static func insertItem(tvc: ScheduleTableViewController, item: ScheduleItem, newStartTime: Int, insertOption: InsertOption) {
        var scheduleItems = tvc.scheduleItems
        item.startTime = newStartTime
        let origRow = scheduleItems.count - 1
        var i = origRow
        //find correct previous item
        swapLoop: while(i >= 0) {
            i -= 1
            if i == -1 || (item.startTime! > scheduleItems[i].startTime! || (item.startTime! == scheduleItems[i].startTime! && insertOption == .extend)) {
                break swapLoop
            }
        }
        //if extending duration, must take "prev prev" item
        if (insertOption == .extend) {
            i -= 1
        }
        let prev = origRow > 0 ? scheduleItems[origRow - 1] : nil
        if origRow > 0 && item.startTime! >= prev!.startTime! + prev!.duration  {
            prev!.duration = item.startTime! - prev!.startTime!
        }
        else {
            var splitItem: ScheduleItem!
            //let curr = scheduleItems[i+1]
            var diff = 0
            var newPrev: ScheduleItem!
            if (i >= 0) {
                newPrev = scheduleItems[i]
                diff = newPrev.startTime! + newPrev.duration - item.startTime!
                newPrev.duration -= diff
                
                
            }
            
            scheduleItems.insert(item, at: i + 1)
            
            if(i >= 0 && insertOption == .split && diff != 0) {
                splitItem = ScheduleItem(name: newPrev.taskName, duration: diff, startTime: item.startTime! + item.duration)
                scheduleItems.insert(splitItem, at: i + 2)
            }
            
            
        }
        tvc.scheduleItems = scheduleItems
        tvc.update()
    }
    @IBAction func durationEditing(_ sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        
        datePickerView.datePickerMode = UIDatePickerMode.countDownTimer
        
        sender.inputView = datePickerView
        
        let date = Date(timeInterval: Double(scheduleItem.duration), since: startOfToday)
        datePickerView.setDate(date, animated: true)
       
        //datePickerView.addTarget(self, action: #selector(ScheduleTableViewCell.datePickerValueChanged), for: UIControlEvents.valueChanged)
    }
   
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        
        
        let duration = sender.countDownDuration
        scheduleItem.duration = Int(duration)
        durationTF.text = durationDescription(duration: scheduleItem.duration)
        if let startTime = scheduleItem.startTime {
            let endTime = startTime + Int(duration)
            endTimeTF.text = timeDescription(durationSinceMidnight: endTime)
            
        }
        tableViewController.update()
    }
    @objc func doneDurationEditing(sender:UIButton) {
        
        
        let duration = (durationTF.inputView as! UIDatePicker).countDownDuration
        scheduleItem.duration = Int(duration)
        durationTF.text = durationDescription(duration: scheduleItem.duration)
        if let startTime = scheduleItem.startTime {
            let endTime = startTime + Int(duration)
            endTimeTF.text = timeDescription(durationSinceMidnight: endTime)
            
        }
        tableViewController.update()
    }
    
    //MARK: Helper functions
    func timeDescription(durationSinceMidnight: Int) -> String {
        /*
        if(durationSinceMidnight / 3600 < 13) {
            return "\(Int(durationSinceMidnight) / 3600):\((Int(durationSinceMidnight) % 3600) / 60) AM"
        }
        else if(durationSinceMidnight / 3600 < 24){
            return "\(Int(durationSinceMidnight) / 3600 - 12):\((Int(durationSinceMidnight) % 3600) / 60) PM"
        }
        else {
            return "ERROR: durationSinceMidnight greater than a day"
        }
        */
        let is24Mode = appDelegate.userSettings.is24Mode
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        let date = startOfToday.addingTimeInterval(Double(durationSinceMidnight))
        var text = formatter.string(from: date)
        if durationSinceMidnight >= 13 * 3600 {
            text = text + " "
        }
        if(is24Mode) {
            let hour = String(durationSinceMidnight / 3600)
            var minute = String((durationSinceMidnight % 3600) / 60)
            if (durationSinceMidnight % 3600) / 60 < 10 {
                minute = "0" + minute
            }
            text = hour + ":" + minute
        }
        if durationSinceMidnight < 10 * 3600 {
            text = text + " "
        }
        /*
        let attributedString = NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.font : UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .regular)])
        if durationSinceMidnight < 10 * 3600 || (!is24Mode && durationSinceMidnight >= 13 * 3600) {
            attributedString.setAttributes([NSAttributedStringKey.foregroundColor : UIColor(white: 0.0, alpha: 0.0)], range: NSRange(text.count - 1..<text.count))
        }
        return attributedString
        */
        return text
        //return "ERROR: durationSinceMidnight greater than a day"
    }
    func durationDescription(duration: Int) -> String {
        let hour:Int = duration / 3600
        let minute:Int = (duration % 3600) / 60
        var hourString = "\(hour)"
        var minuteString = "\(minute)"
        if(hour < 10) {
            hourString = "0" + hourString
        }
        if(minute < 10) {
            minuteString = "0" + minuteString
        }
       
        return "\(hourString):\(minuteString)"
        
    }
    func setStyle(textField: UITextField) {
        textField.layer.cornerRadius = 0
        /*
        if(textField == startTimeTF || textField == durationTF) {
            textField.font = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .regular)
        }
        */
        
    }
    //MARK: Actions
    
    @IBAction func lockButtonPressed(_ sender: UIButton) {
        if (scheduleItem.startTime != nil) {
            scheduleItem.locked = !scheduleItem.locked
            sender.setTitle(scheduleItem.locked ? "🔒" : "🌀",for: .normal)
            tableViewController.update()
        }
    }
}
