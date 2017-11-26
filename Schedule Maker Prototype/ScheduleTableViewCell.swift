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


class ScheduleTableViewCell: UITableViewCell, UITextFieldDelegate {
    
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
        }
    }
    
    
    @IBOutlet weak var startTimeTF: UITextField!
    @IBOutlet weak var endTimeTF: UITextField!
    @IBOutlet weak var taskNameTF: UITextField!
    @IBOutlet weak var durationTF: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        taskNameTF.delegate = self
        durationTF.delegate = self
        
        //set midnight as a global Date variable
       
        startOfToday = Calendar.current.startOfDay(for: Date())
        let textFields = self.subviews[0].subviews.filter{$0 is UITextField}
        for i in textFields {
            setStyle(textField: (i as! UITextField))
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
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
        
        datePickerView.addTarget(self, action: #selector(ScheduleTableViewCell.datePickerValueChangedStartTime), for: UIControlEvents.valueChanged)
 
    }
    @objc func datePickerValueChangedStartTime(sender:UIDatePicker) {
        let date = sender.date
        //update startTime and endTime based on chosen date
        scheduleItem.startTime = Int(date.timeIntervalSince(startOfToday))
        
        startTimeTF.text = timeDescription(durationSinceMidnight: scheduleItem.startTime!)
        let endTime = scheduleItem.startTime! + scheduleItem.duration
        endTimeTF.text = timeDescription(durationSinceMidnight: endTime)
        
        var scheduleItems = tableViewController.scheduleItems
        //update the previous cell's duration to match current cell's new start time
        var i = row!
        swapLoop: while(i >= 0) {
            i -= 1
            if i == -1 || scheduleItem.startTime! > scheduleItems[i].startTime! {
                break swapLoop
            }
        }
      
        scheduleItems.insert(scheduleItems.remove(at: row), at: i + 1)
        if (i >= 0) {
            let prev = scheduleItems[i]
            prev.duration = scheduleItem.startTime! - prev.startTime!
        }
        
        
        tableViewController.scheduleItems = scheduleItems
        tableViewController.update()
        
    }
    
    @IBAction func durationEditing(_ sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        
        datePickerView.datePickerMode = UIDatePickerMode.countDownTimer
        
        sender.inputView = datePickerView
        
        let date = Date(timeInterval: Double(scheduleItem.duration), since: startOfToday)
        datePickerView.setDate(date, animated: true)
       
        datePickerView.addTarget(self, action: #selector(ScheduleTableViewCell.datePickerValueChanged), for: UIControlEvents.valueChanged)
        print("durationEdited")
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
    
}
