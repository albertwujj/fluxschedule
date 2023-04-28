//
//  RecurringTaskTableViewCell.swift
//  Schedule Maker Prototype
//
//  Created by Albert Wu on 12/31/17.
//  Copyright © 2017 Old Friend. All rights reserved.
//

import UIKit
let appDelegate = UIApplication.shared.delegate as! AppDelegate
var startOfToday: Date!

class RecurringTaskTableViewCell: UITableViewCell, UITextFieldDelegate {
  var tvcontroller: RecurringTasksTableViewController!
  var scheduleItem: ScheduleItem! {
    //Have cell display proper TextField content based on ScheduleItem data
    didSet {
      taskNameTF.text = scheduleItem.taskName
      durationTF.text = durationDescription(duration: scheduleItem.duration)
      if let startTime = scheduleItem.startTime {
        startTimeTF.text = timeDescription(durationSinceMidnight: startTime)
        //let endTime = startTime + scheduleItem.duration
        //endTimeTF.text = timeDescription(durationSinceMidnight: endTime)
      }
      else {
        startTimeTF.text = "XX:XX"
        //endTimeTF.text = "XX:XX"
      }
      lockButton.setTitle(scheduleItem.locked ? "🔒" : "🌀", for: .normal)
      weekdaySelection.chosenWeekdays = scheduleItem.recurDays!
      for i in weekdaySelection.chosenWeekdays {
        weekdaySelection.weekdayButtons[i].isPressed = true
      }
      weekdaySelection.tvcell = self
    }
  }
  @IBOutlet weak var taskNameTF: UITextField!
  @IBOutlet weak var weekdaySelection: WeekdaySelection!
  @IBOutlet weak var startTimeTF: UITextField!
  @IBOutlet weak var durationTF: UITextField!
  
  @IBOutlet weak var lockButton: UIButton!
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    startOfToday = Calendar.current.startOfDay(for: Date())
    taskNameTF.delegate = self
    startTimeTF.delegate = self
    durationTF.delegate = self
    
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  //UITextFieldDelegateFunctions
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    tvcontroller.vc.backButton.isEnabled = false
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
    tvcontroller.vc.backButton.isEnabled = true
  }
  
  //MARK: Input handling
  @IBAction func startTimeEditing(_ sender: UITextField) {
    let datePickerView:UIDatePicker = UIDatePicker()
    datePickerView.datePickerMode = UIDatePickerMode.time
    sender.inputView = datePickerView
    
    let date = Date(timeInterval: Double(scheduleItem.startTime ?? 7 * 3600), since: startOfToday)
    datePickerView.setDate(date, animated: true)
    
    
  }
  
  @objc func doneStartTimeEditing(sender:UIButton) {
    let date = (startTimeTF.inputView as! UIDatePicker).date
    //update startTime and endTime based on chosen date
    
    
    if isRecurConflict(startTime1: Int(date.timeIntervalSince(startOfToday)), duration: scheduleItem.duration, recurDays: scheduleItem.recurDays!, message: "New start time") {
      return
    }
    scheduleItem.startTime = Int(date.timeIntervalSince(startOfToday))
    startTimeTF.text = timeDescription(durationSinceMidnight: scheduleItem.startTime!)
    startTimeTF.resignFirstResponder()
  }
  
  @IBAction func durationEditing(_ sender: UITextField) {
    let datePickerView:UIDatePicker = UIDatePicker()
    
    datePickerView.datePickerMode = UIDatePickerMode.countDownTimer
    
    sender.inputView = datePickerView
    
    let date = Date(timeInterval: Double(scheduleItem.duration), since: startOfToday)
    datePickerView.setDate(date, animated: true)
  }
  @objc func doneDurationEditing(sender: UIButton) {
    
    let duration = (durationTF.inputView as! UIDatePicker).countDownDuration
    if let startTime = scheduleItem.startTime {
      if isRecurConflict(startTime1: startTime, duration: Int(duration), recurDays: scheduleItem.recurDays!, message: "New duration") {
        return
      }
    }
    scheduleItem.duration = Int(duration)
    durationTF.text = durationDescription(duration: scheduleItem.duration)
    durationTF.resignFirstResponder()
  }
  func isRecurConflict(startTime1: Int, duration: Int, recurDays: Set<Int>, message: String) -> Bool {
    let endTime1 = startTime1 + duration
    for task in tvcontroller.rTasks {
      if task !== scheduleItem {
        if let tStartTime = task.startTime {
          for movedDay in recurDays {
            if task.recurDays!.contains(movedDay) {
              let startTime2 = tStartTime
              let endTime2 = tStartTime + task.duration
              if (startTime1 < startTime2 && endTime1 > startTime2) || (startTime1 < endTime2 && endTime1 > endTime2) {
                let alertController = UIAlertController(title: "Recurring event conflict", message: "\(message) would cause event \"\(scheduleItem.taskName)\" to conflict with event \"\(task.taskName)\".", preferredStyle: UIAlertControllerStyle.alert)
                
                let okAction = UIAlertAction(title: "Cancel change", style: UIAlertActionStyle.default)
                {
                  (result : UIAlertAction) -> Void in
                }
                alertController.addAction(okAction)
                tvcontroller.present(alertController, animated: true, completion: nil)
                return true
              }
              break
            }
          }
        }
      }
    }
    return false
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
  @IBAction func lockButtonPressed(_ sender: UIButton) {
    scheduleItem.locked = !scheduleItem.locked
    sender.setTitle(scheduleItem.locked ? "🔒" : "🌀",for: .normal)
    tvcontroller.saveRTasks()
  }
}
