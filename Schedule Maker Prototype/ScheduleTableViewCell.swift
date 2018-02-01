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
    
    @IBOutlet weak var startTimeWidthConstraint: NSLayoutConstraint!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let userSettings = (UIApplication.shared.delegate as! AppDelegate).userSettings
    var tableViewController: ScheduleTableViewController!
    var startOfToday: Date!
    var row: Int!
    var scheduleItem: ScheduleItem! {
        //Have cell display proper TextField content based on ScheduleItem data
        didSet {
            taskNameTF.text = scheduleItem.taskName
            if userSettings.is5MinIncrement {
                durationTF.text = ScheduleTableViewCell.durationDescription(duration: roundTo5(integer: scheduleItem.duration))
            }
            else {
                durationTF.text = ScheduleTableViewCell.durationDescription(duration: scheduleItem.duration)
            }
            
            if let startTime = scheduleItem.startTime {
                if userSettings.is5MinIncrement {
                    startTimeTF.text = ScheduleTableViewCell.timeDescription(durationSinceMidnight: roundTo5(integer: startTime))
                } else {
                    startTimeTF.text = ScheduleTableViewCell.timeDescription(durationSinceMidnight: startTime)
                }
                
            }
            else {
                startTimeTF.text = "XX:XX"
                endTimeTF.text = "XX:XX"
            }
            lockButtonUpdated()
        }
    }
    
    
    @IBOutlet weak var startTimeTF: AccessoryTextField!
    var startTimeTFCustomButton: UIButton!
    var durationTFCustomButton: UIButton!
    @IBOutlet weak var endTimeTF: UITextField!
    @IBOutlet weak var taskNameTF: UITextField!
    @IBOutlet weak var durationTF: AccessoryTextField!
    
    @IBOutlet weak var lockButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let textFields = self.subviews[0].subviews.filter{$0 is UITextField}
        for i in textFields {
            let tf = i as! UITextField
            setStyle(textField: tf)
            if UIScreen.main.bounds.width < 330 {
                if appDelegate.scheduleViewController.tutorialStep != 0 {
                    
                    tf.font = UIFont.systemFont(ofSize: 11)
                    startTimeWidthConstraint.constant = 68
                    
                } else {
                    
                    tf.font = UIFont.systemFont(ofSize: 13)
                    startTimeWidthConstraint.constant = 72
                    
                }
            } else {
                startTimeWidthConstraint.constant = 81
            }
        }
        startTimeTF.delegate = self
        durationTF.delegate = self
        taskNameTF.delegate = self
        //set midnight as a global Date variable
       
        startOfToday = Calendar.current.startOfDay(for: Date())
        startTimeTF.accessoryDelegate = self
        durationTF.accessoryDelegate = self
        startTimeTFCustomButton = UIButton()
        startTimeTFCustomButton.setTitle(" 88:88 AM ", for: .normal)
        startTimeTFCustomButton.setTitleColor(.black, for: .normal)
        durationTFCustomButton = UIButton()
        durationTFCustomButton.setTitle(" 88:88 ", for: .normal)
        durationTFCustomButton.setTitleColor(.black, for: .normal)
        startTimeTF.addButtons(customString: nil, customButton: startTimeTFCustomButton)
        durationTF.addButtons(customString: nil, customButton: durationTFCustomButton)
        Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(updateStartOfToday), userInfo: nil, repeats: true)
    }
    
    @objc func updateStartOfToday() {
        startOfToday = Calendar.current.startOfDay(for: Date())
    }
    func changeFontForScreenSize(tvc: ScheduleTableViewController) {
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    //AccessoryTextFieldDelegateFunctions
    func textFieldContainerButtonPressed(_ sender: AccessoryTextField) {
        if sender === startTimeTF {
            
        }
        else if sender === durationTF {
            
        }
    }
    func textFieldCancelButtonPressed(_ sender: AccessoryTextField) {
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            sender.backgroundColor = .white
            
        }, completion: { (finished) -> Void in
            
        })
        sender.resignFirstResponder()
    }
    func textFieldDoneButtonPressed(_ sender: AccessoryTextField) {
        //if !sender.inputView!.isScrolling() {
            sender.resignFirstResponder()
        let origScheduleItem = self.scheduleItem!
        let tvc = tableViewController!
            if sender === startTimeTF{
                
                let intDate = Int((startTimeTF.inputView as! UIDatePicker).date.timeIntervalSince(startOfToday))
                if intDate == scheduleItem.startTime ?? 0 {
                    UIView.animate(withDuration: 0.4, animations: { () -> Void in
                        sender.backgroundColor = .white
                        
                    }, completion: { (finished) -> Void in
                        
                    })
                    return
                }
                
                if row == 0 {
                    scheduleItem.startTime = intDate
                    tvc.update()
                    return
                } 
                if row > 0 && intDate > tableViewController.scheduleItems[row - 1].startTime! && intDate < scheduleItem.startTime! {
                    tvc.scheduleItems[row-1].duration = intDate - tvc.scheduleItems[row - 1].startTime!
                    tvc.update()
                    return
                }
                if row < tvc.scheduleItems.count - 1 && intDate < tvc.scheduleItems[row + 1].startTime! && intDate > scheduleItem.startTime! {
                    if(row > 0) {
                        tvc.scheduleItems[row - 1].duration = intDate - tvc.scheduleItems[row - 1].startTime!
                    }
                    else {
                        scheduleItem.startTime = intDate
                    }
                    tvc.update()
                    return
                }
                //let scheduleItem = self.scheduleItem!
                for compared in tableViewController.scheduleItems {
                    if compared.startTime != nil && compared.locked && compared !== scheduleItem {
                        if intDate > compared.startTime! && intDate < compared.startTime! + compared.duration {
                            let alertController = UIAlertController(title: "Locked item conflict", message: "New start time would cause conflict with locked item \"\(compared.taskName)\".", preferredStyle: UIAlertControllerStyle.alert)
                            
                            let okAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default)
                            {
                                (result : UIAlertAction) -> Void in
                            }
                            alertController.addAction(okAction)
                            tableViewController.present(alertController, animated: true, completion: nil)
                            return

                        }
                    }
                }
                if scheduleItem.locked {
                    let alertController = UIAlertController(title: "Item is locked!", message: "Cannot change the start time of a locked time.", preferredStyle: UIAlertControllerStyle.alert)
                    
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
                    {
                        (result : UIAlertAction) -> Void in
                    }
                    alertController.addAction(okAction)
                    tableViewController.present(alertController, animated: true, completion: nil)
                    return
                }
                
                //update startTime and endTime based on chosen date
                scheduleItem.startTime = intDate
                
                if userSettings.is5MinIncrement {
                    startTimeTF.text = ScheduleTableViewCell.timeDescription(durationSinceMidnight: roundTo5(integer: scheduleItem.startTime!))
                }
                else {
                    startTimeTF.text = ScheduleTableViewCell.timeDescription(durationSinceMidnight: scheduleItem.startTime!)
                }
                
                var origLockedItems = tableViewController.getLockedItems()
                
                if true || origLockedItems.count > 0 {
                    tableViewController.scheduleItems.remove(at: self.row)
                    origLockedItems.append(scheduleItem.deepCopy())
                    tableViewController.recalculateTimes(with: origLockedItems)
                    tableViewController.update()
                }
                else {
                    ScheduleTableViewCell.moveItem(tvc: tableViewController, origRow: row!, newStartTime: scheduleItem.startTime!, insertOption: appDelegate.userSettings.insertOption)
                }
     
                tableViewController.flashScheduleItem(intDate, for: 0, color: UIColor.purple)
            }
            else if sender === durationTF {
                let intDate = origScheduleItem.startTime ?? 0
                let duration = (durationTF.inputView as! UIDatePicker).countDownDuration
                if Int(duration) == scheduleItem.duration {
                    UIView.animate(withDuration: 0.4, animations: { () -> Void in
                        sender.backgroundColor = .white
                        
                    }, completion: { (finished) -> Void in
                    })
                    return
                }
                
                scheduleItem.duration = Int(duration)
                tableViewController.scheduleItems.remove(at: self.row)
                var origLockedItems = tableViewController.getLockedItems()
                origLockedItems.append(scheduleItem.deepCopy())
                tableViewController.recalculateTimes(with: origLockedItems)
                tableViewController.update()
                tableViewController.flashScheduleItem(intDate, for: 1, color: UIColor.purple)
            }
        tableViewController.scheduleViewController.schedulesEdited.insert(tableViewController.currDateInt)
    }
    //MARK: UITextFieldDelegateFunctions
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField is AccessoryTextField {
            let accessoryTF = textField as! AccessoryTextField
            let bgColorView = UIView()
         
            let orig = UIColor.purple
            UIView.animate(withDuration: 0.4, animations: { () -> Void in
                accessoryTF.backgroundColor = orig.withAlphaComponent(0.3)
                
            }, completion: { (finished) -> Void in
                
            })
            
            
        }
        if textField === taskNameTF {
            if taskNameTF.text?.range(of: "New Item \\d*", options: .regularExpression, range: nil, locale: nil) != nil {
                taskNameTF.selectAll(nil)
            }
        }
        if textField === startTimeTF || textField === durationTF {
            var desiredPosition: UITextPosition = textField.endOfDocument
            if(textField.text?.last != nil && textField.text!.last! == " ") {
                desiredPosition = textField.position(from: desiredPosition, offset: -1) ?? desiredPosition
            }
            //textField.selectedTextRange = textField.textRange(from: desiredPosition, to: desiredPosition)
            textField.selectedTextRange = nil
            textField.isHighlighted = true
        }
        
        
    }
    @objc func checkEnableDoneButton(timer: Timer) {
        let accessoryTF = timer.userInfo as! AccessoryTextField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == taskNameTF {
            scheduleItem.taskName = textField.text ?? ""
            if textField.text?.range(of: "New Item \\d", options: .regularExpression, range: nil, locale: nil) != nil {
                tableViewController.scheduleViewController.schedulesEdited.insert(tableViewController.currDateInt)
            }
        }
        else if textField == durationTF {
            
        }
        else if textField == startTimeTF {
          
        }
        if textField is AccessoryTextField {
            UIView.animate(withDuration: 0.8, animations: { () -> Void in
                textField.backgroundColor = .white
                
            }, completion: { (finished) -> Void in
                
            })
        }
        tableViewController.update()
    }
    
    //MARK: Input handling
    @IBAction func startTimeEditing(_ sender: UITextField) {
        if !scheduleItem.locked {
            let datePickerView:UIDatePicker = UIDatePicker()
            datePickerView.datePickerMode = UIDatePickerMode.time
            sender.inputView = datePickerView
            var date: Date!
            if(userSettings.is5MinIncrement) {
                date = Date(timeInterval: Double(roundTo5(integer: (scheduleItem.startTime ?? 7 * 3600))), since: startOfToday)
                datePickerView.minuteInterval = 5
                print(roundTo5(integer: scheduleItem.startTime!))
            }
            else {
                date = Date(timeInterval: Double(scheduleItem.startTime ?? 7 * 3600), since: startOfToday)
            }
            datePickerView.setDate(date, animated: true)
            startTimeTFCustomButton.setTitle(ScheduleTableViewCell.timeDescription(durationSinceMidnight: Int(date.timeIntervalSince(startOfToday))), for: .normal)
            startTimeTFCustomButton.sizeToFit()
            datePickerView.addTarget(self, action: #selector(ScheduleTableViewCell.datePickerValueChangedStartTime), for: UIControlEvents.valueChanged)
        }
 
    }
    @objc func datePickerValueChangedStartTime(sender:UIDatePicker) {
        
        startTimeTFCustomButton.setTitle(ScheduleTableViewCell.timeDescription(durationSinceMidnight: Int(sender.date.timeIntervalSince(startOfToday))), for: .normal)
        startTimeTFCustomButton.sizeToFit()
        
    }
    @IBAction func durationEditing(_ sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.countDownTimer
        sender.inputView = datePickerView
        var date: Date!
        if(userSettings.is5MinIncrement) {
            date = Date(timeInterval: Double(roundTo5(integer: scheduleItem.duration)), since: startOfToday)
            datePickerView.minuteInterval = 5
            
        }
        else {
            date = Date(timeInterval: Double(scheduleItem.duration), since: startOfToday)
        }
        datePickerView.setDate(date, animated: true)
        durationTFCustomButton.setTitle(" \(ScheduleTableViewCell.durationDescription(duration: Int(date.timeIntervalSince(startOfToday)))) ", for: .normal)
        durationTFCustomButton.sizeToFit()
        datePickerView.addTarget(self, action: #selector(ScheduleTableViewCell.datePickerValueChanged), for: UIControlEvents.valueChanged)
        
    }
    func roundTo5(integer: Int) -> Int {
        return Int((Double(integer / 60) + 2.5) / Double(5).rounded(.down)) * 5 * 60
    }
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        durationTFCustomButton.setTitle(ScheduleTableViewCell.durationDescription(duration: Int(sender.countDownDuration)), for: .normal)
        durationTFCustomButton.sizeToFit()
    }
    @objc func doneStartTimeEditing(sender: UIBarButtonItem) {
        let date = (startTimeTF.inputView as! UIDatePicker).date
        //update startTime and endTime based on chosen date
        scheduleItem.startTime = Int(date.timeIntervalSince(startOfToday))
        
        if userSettings.is5MinIncrement {
            startTimeTF.text = ScheduleTableViewCell.timeDescription(durationSinceMidnight: roundTo5(integer: scheduleItem.startTime!))
        }
        else {
            startTimeTF.text = ScheduleTableViewCell.timeDescription(durationSinceMidnight: scheduleItem.startTime!)
        }
        let endTime = scheduleItem.startTime! + scheduleItem.duration
        endTimeTF.text = ScheduleTableViewCell.timeDescription(durationSinceMidnight: endTime)
        
       // ScheduleTableViewCell.moveItem(tvc: tableViewController, origRow: row!, newStartTime: scheduleItem.startTime!, insertOption: appDelegate.userSettings.insertOption)
    }

    static func moveItem(tvc: ScheduleTableViewController, origRow: Int, newStartTime: Int, insertOption: InsertOption) -> IndexPath?{
     
        let tableView = tvc.tableView!
        var finalRow = 0
        var scheduleItems = tvc.scheduleItems
        let scheduleItem = scheduleItems[origRow]
        scheduleItem.startTime = newStartTime
        var prevRow = origRow
      
        //find correct previous item
        swapLoop: while(prevRow >= 0) {
            prevRow -= 1
            if prevRow == -1 || (scheduleItem.startTime! > scheduleItems[prevRow].startTime! || (scheduleItem.startTime! == scheduleItems[prevRow].startTime! && insertOption == .extend)) {
                break swapLoop
            }
        }
        //if extending duration, must take "prev prev" item
       
        
        let prev = origRow > 0 ? scheduleItems[origRow - 1] : nil
        var isExtension = false
        if origRow > 0 && scheduleItem.startTime! >= prev!.startTime! + prev!.duration  {
            isExtension = true
        }
       
        var splitItem: ScheduleItem!
        //let curr = scheduleItems[i+1]
        var diff = 0
        var newPrev: ScheduleItem!
        if (prevRow >= 0) {
            newPrev = scheduleItems[prevRow]
            if newPrev.locked == true {
                let alertController = UIAlertController(title: "Locked item conflict", message: "New start time would cause item \"\(scheduleItem.taskName)\" to conflict with locked item \"\(newPrev.taskName)\".", preferredStyle: UIAlertControllerStyle.alert)
                
                let okAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default)
                {
                    (result : UIAlertAction) -> Void in
                }
                alertController.addAction(okAction)
                tvc.present(alertController, animated: true, completion: nil)
                return nil
            }
            diff = newPrev.startTime! + newPrev.duration - scheduleItem.startTime!
            newPrev.duration -= diff
        
    
            //cell.startTimeTF.text = "\(cell.timeDescription(durationSinceMidnight: newStartTime))"
            
            
           
            
            
        }
        finalRow = prevRow + 1
        var finalRowWOffset = finalRow
        
        if (origRow < finalRow) {
            finalRowWOffset -= 1
          
        }
        if origRow != finalRow {
            scheduleItems.insert(scheduleItems.remove(at: origRow), at: finalRowWOffset)
        }
            
        if(finalRow != origRow && prevRow >= 0 && insertOption == .split && diff > 0) {
            splitItem = ScheduleItem(name: newPrev.taskName, duration: diff, startTime: scheduleItem.startTime! + scheduleItem.duration)
            scheduleItems.insert(splitItem, at: finalRowWOffset+1)
        }
        
        
        tvc.scheduleItems = scheduleItems
        
        tvc.update()
        return IndexPath(finalRow)
    }
    /*
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
    */
    @objc func doneDurationEditing(sender:UIButton) {
        
        
        let duration = (durationTF.inputView as! UIDatePicker).countDownDuration
        scheduleItem.duration = Int(duration)
        if userSettings.is5MinIncrement {
            durationTF.text = ScheduleTableViewCell.durationDescription(duration: roundTo5(integer: scheduleItem.duration))
        }
        else {
            durationTF.text = ScheduleTableViewCell.durationDescription(duration: scheduleItem.duration)
        }
        if let startTime = scheduleItem.startTime {
            let endTime = startTime + Int(duration)
            endTimeTF.text = ScheduleTableViewCell.timeDescription(durationSinceMidnight: endTime)
            
        }
        tableViewController.update()
    }
    
    //MARK: Helper functions
    static func timeDescription(durationSinceMidnight: Int) -> String {
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
        let is24Mode = (UIApplication.shared.delegate as! AppDelegate).userSettings.is24Mode
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        let date = Calendar.current.startOfDay(for: Date()).addingTimeInterval(Double(durationSinceMidnight))
        var text = formatter.string(from: date)
        if durationSinceMidnight >= 13 * 3600 {
            //text = text + " "
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
            //text = text + " "
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
    static func durationDescription(duration: Int) -> String {
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
        /*
        textField.layer.cornerRadius = 7
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor.purple.withAlphaComponent(0.2).cgColor
        */
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
            lockButtonUpdated()
        }
    }
    func lockButtonUpdated() {
        if scheduleItem.locked {
            startTimeTF.isUserInteractionEnabled = false
            if tableViewController.testingMode {
                scheduleItem.taskName = ScheduleTableViewCell.timeDescription(durationSinceMidnight: scheduleItem.startTime!)
                taskNameTF.text = scheduleItem.taskName
            }
        } else {
            startTimeTF.isUserInteractionEnabled = true
        }
        
        lockButton.setTitle(scheduleItem.locked ? "🔒" : "🌀",for: .normal)
        appDelegate.scheduleViewController.stepLockedComplete()
        
    }
}
