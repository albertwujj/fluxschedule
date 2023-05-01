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

//iPhone UIKit Sizes: //https://developer.apple.com/library/archive/documentation/DeviceInformation/Reference/iOSDeviceCompatibility/Displays/Displays.html
//https://www.ios-resolution.com/

class ScheduleTableViewCell: UITableViewCell, AccessoryTextFieldDelegate, UITextFieldDelegate {

  @IBOutlet weak var durationWidthConstraint: NSLayoutConstraint!
  @IBOutlet weak var startTimeWidthConstraint: NSLayoutConstraint!
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  let userSettings = (UIApplication.shared.delegate as! AppDelegate).userSettings
  var tvc: ScheduleTableViewController!
  var svc: ScheduleViewController!
  var startOfToday: Date!
  var origScheduleItem:ScheduleItem?
  var row: Int!
  var origRow: Int?
  var scheduleItem: ScheduleItem! {
    //Have cell display proper TextField content based on ScheduleItem data
    didSet {
      taskNameTF.text = scheduleItem.taskName
      durationTF.text = ScheduleTableViewCell.durationDescription(duration: scheduleItem.duration)

      if let startTime = scheduleItem.startTime {
        startTimeTF.text = ScheduleTableViewCell.timeDescription(durationSinceMidnight: startTime)
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
    svc = appDelegate.svc
    fitToScreenSize()
    startTimeTF.delegate = self
    durationTF.delegate = self
    taskNameTF.delegate = self
    //set midnight as a global Date variable

    startOfToday = Calendar.current.startOfDay(for: Date())
    startTimeTF.accessoryDelegate = self
    durationTF.accessoryDelegate = self
    startTimeTFCustomButton = UIButton()
    startTimeTFCustomButton.setTitle("    88:88    ", for: .normal)
    startTimeTFCustomButton.setTitleColor(.black, for: .normal)
    durationTFCustomButton = UIButton()
    durationTFCustomButton.setTitle("    88:88    ", for: .normal)
    durationTFCustomButton.setTitleColor(.black, for: .normal)
    startTimeTF.addButtons(customString: nil, customButton: startTimeTFCustomButton)
    durationTF.addButtons(customString: nil, customButton: durationTFCustomButton)
    Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(updateStartOfToday), userInfo: nil, repeats: true)

  }
  func fitToScreenSize() {
    //fits TFs height to screen size by changing font size based on screen size
    let textFields = [startTimeTF, taskNameTF, durationTF]
    for i in textFields {
      let tf = i!
      //setStyle(textField: tf)
      fitToScreenSize(textField: tf)
    }
    //adjust TFs to fit font size
    adjustTimeTFs()
  }

  //adjust TFs to fit font size
  func adjustTimeTFs() {
    if !using12hClockFormat() {
      startTimeWidthConstraint.constant = startTimeTF.getMinWidthThatFits(text: "24:44")
    } else {
      startTimeWidthConstraint.constant = startTimeTF.getMinWidthThatFits(text: "24:44 AM")
    }
    durationWidthConstraint.constant = durationTF.getMinWidthThatFits(text: "24:44")
  }


  func using12hClockFormat() -> Bool {

    let formatter = DateFormatter()
    formatter.locale = Locale.current
    formatter.dateStyle = .none
    formatter.timeStyle = .short

    let dateString = formatter.string(from: Date())
    let amRange = dateString.range(of: formatter.amSymbol)
    let pmRange = dateString.range(of: formatter.pmSymbol)

    return !(pmRange == nil && amRange == nil)
  }
  @objc func updateStartOfToday() {
    startOfToday = Calendar.current.startOfDay(for: Date())
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

    let scheduleItem = self.origScheduleItem ?? self.scheduleItem!
    let origScheduleItem = scheduleItem
    let row = origRow ?? self.row!

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
        return
      }
      //shrinks prev task
      if row > 0 && intDate > tvc.scheduleItems[row - 1].startTime! && intDate < scheduleItem.startTime! {
        tvc.scheduleItems[row-1].duration = intDate - tvc.scheduleItems[row - 1].startTime!
        tvc.itemsToRed.append(tvc.scheduleItems[row-1])
        return
      }
      //increases prev task
      if row < tvc.scheduleItems.count - 1 && intDate < tvc.scheduleItems[row + 1].startTime! && intDate > scheduleItem.startTime! {
        if(row > 0) {
          tvc.scheduleItems[row - 1].duration = intDate - tvc.scheduleItems[row - 1].startTime!
          tvc.itemsToGreen.append(tvc.scheduleItems[row-1])
        }
        else {
          scheduleItem.startTime = intDate
        }
        return
      }
      //let scheduleItem = self.scheduleItem!
      for compared in tvc.scheduleItems {
        if compared.startTime != nil && compared.locked && compared !== scheduleItem {
          if intDate > compared.startTime! && intDate < compared.startTime! + compared.duration {
            let alertController = UIAlertController(title: "Locked item conflict", message: "New start time would cause conflict with locked item \"\(compared.taskName)\".", preferredStyle: UIAlertControllerStyle.alert)

            let okAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default)
            {
              (result : UIAlertAction) -> Void in
            }
            alertController.addAction(okAction)
            tvc.present(alertController, animated: true, completion: nil)
            return
          }
        }
      }
      if scheduleItem.locked {
        let alertController = UIAlertController(title: "Item is locked!", message: "Cannot change the start time of a locked tasks.", preferredStyle: UIAlertControllerStyle.alert)

        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
        {
          (result : UIAlertAction) -> Void in
        }
        alertController.addAction(okAction)
        tvc.present(alertController, animated: true, completion: nil)
        return
      }

      //update startTime and endTime based on chosen date
      scheduleItem.startTime = intDate

      startTimeTF.text = ScheduleTableViewCell.timeDescription(durationSinceMidnight: scheduleItem.startTime!)

      var origLockedItems = tvc.getLockedItems()

      tvc.scheduleItems.remove(at: self.row)
      origLockedItems.append(scheduleItem.deepCopy())
      tvc.recalculateTimes(with: origLockedItems)
      tvc.updateNoRecalculate()

      tvc.flashScheduleItem(intDate, for: 0, color: UIColor.purple)
    }
    else if sender === durationTF {
      let intDate = origScheduleItem.startTime ?? 0
      let duration = (durationTF.inputView as! GSTimeIntervalPicker).timeInterval
      if Int(duration) == scheduleItem.duration {
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
          sender.backgroundColor = .white

        }, completion: { (finished) -> Void in
        })
        return
      }

      scheduleItem.duration = Int(duration)
      tvc.scheduleItems.remove(at: self.row)
      var origLockedItems = tvc.getLockedItems()
      origLockedItems.append(scheduleItem.deepCopy())
      tvc.recalculateTimes(with: origLockedItems)
      tvc.update()
      tvc.flashScheduleItem(intDate, for: 1, color: UIColor.purple)
    }
    tvc.scheduleViewController.schedulesEdited.insert(tvc.dateInt)
  }
  //MARK: UITextFieldDelegateFunctions
  func textFieldDidBeginEditing(_ textField: UITextField) {
    setupTFForEdit(textField)
  }
  func setupTFForEdit(_ textField: UITextField) {
    tvc.activeTextField = textField
    tvc.duringKeyboardScroll = false
    tvc.quickReloadCells()
    tvc.duringKeyboardScroll = true
    origScheduleItem = scheduleItem!
    origRow = origRow!
    origScheduleItem = scheduleItem
    for (i, p) in (tvc.tableView.indexPathsForVisibleRows?.enumerated()) ?? [].enumerated() {
      if p.row == row {
        if i > 5 {
          //tableViewController.scrollToBottom(indexPath: IndexPath(row))

        }
      }
    }
    if textField is AccessoryTextField {
      editingAnimation(textField)
    }
    if textField === taskNameTF {
      if taskNameTF.text?.range(of: "\(userSettings.defaultName) *\\d*", options: .regularExpression, range: nil, locale: nil) != nil {
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
  func editingAnimation(_ textField: UITextField) {
    let bgColorView = UIView()
    let orig = UIColor.purple
    UIView.animate(withDuration: 0.4, animations: { () -> Void in
      textField.backgroundColor = orig.withAlphaComponent(0.3)
    }, completion: { (finished) -> Void in

    })
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }
  func textFieldDidEndEditing(_ textField: UITextField) {

    tvc.activeTextField = nil
    if textField == taskNameTF {
      //update name
      scheduleItem.taskName = textField.text ?? ""
      if textField.text?.range(of: "\(userSettings.defaultName) *\\d*", options: .regularExpression, range: nil, locale: nil) == nil {
        tvc.scheduleViewController.schedulesEdited.insert(tvc.dateInt)
      }
      tvc.update()
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
    if textField == taskNameTF && tvc.editItemStep == 2 {
      tvc.editItemStep = 0
    }

    /*
     if let pos = tableViewController.loadScrollPosition() ?? tableViewController.prevScrollPos {
     tableViewController.tableView.scrollToRow(at: pos, at: .top, animated: false)
     tableViewController.prevScrollPos = nil

     }
     */
    if tvc.editItemStep == 1 && textField == startTimeTF{
      tvc.editItemStep = 2
      self.contentView.endEditing(true)


      self.taskNameTF.resignFirstResponder()
      self.taskNameTF.performSelector(onMainThread: #selector(becomeFirstResponder), with: nil, waitUntilDone: false)
    }
  }

  //MARK: Input handling
  @IBAction func startTimeEditing(_ sender: UITextField) {
    if !scheduleItem.locked {
      let datePickerView:UIDatePicker = UIDatePicker()
      datePickerView.datePickerMode = UIDatePickerMode.time
      sender.inputView = datePickerView
      var date: Date!
      if(userSettings.is5MinIncrement) {
        date = Date(timeInterval: Double(ScheduleTableViewCell.roundTo5(integer: (scheduleItem.startTime ?? 7 * 3600))), since: startOfToday)
        datePickerView.minuteInterval = 5

      }
      else {
        date = Date(timeInterval: Double(scheduleItem.startTime ?? 7 * 3600), since: startOfToday)
      }
      datePickerView.setDate(date, animated: true)
      startTimeTFCustomButton.setTitle(ScheduleTableViewCell.timeDescription(durationSinceMidnight: Int(date.timeIntervalSince(startOfToday))), for: .normal)
      startTimeTFCustomButton.sizeToFit()
      datePickerView.addTarget(self, action: #selector(ScheduleTableViewCell.datePickerValueChangedStartTime), for: UIControlEvents.valueChanged)
      datePickerView.preferredDatePickerStyle = .wheels
      datePickerView.sizeToFit()
    }

  }
  @objc func datePickerValueChangedStartTime(sender:UIDatePicker) {
    
    startTimeTFCustomButton.setTitle(ScheduleTableViewCell.timeDescription(durationSinceMidnight: Int(sender.date.timeIntervalSince(startOfToday))), for: .normal)
    startTimeTFCustomButton.sizeToFit()

  }
  @IBAction func durationEditing(_ sender: UITextField) {
    let datePickerView = GSTimeIntervalPicker()
    sender.inputView = datePickerView
    datePickerView.maxTimeInterval = 3600 * 24 - 1
    if(userSettings.is5MinIncrement) {
      datePickerView.timeInterval = TimeInterval(ScheduleTableViewCell.roundTo5(integer: scheduleItem.duration))
      datePickerView.minuteInterval = 5
    }
    else {
      datePickerView.timeInterval = TimeInterval(scheduleItem.duration)
      datePickerView.minuteInterval = 1
    }
    durationTFCustomButton.setTitle(ScheduleTableViewCell.durationDescription(duration: scheduleItem.duration), for: .normal)
    durationTFCustomButton.sizeToFit()
    datePickerView.onTimeIntervalChanged = { (newTimeInterval: TimeInterval) -> Void in
      self.datePickerValueChanged(newTimeInterval: newTimeInterval)
    }

  }
  @objc func datePickerValueChanged(newTimeInterval: TimeInterval) {
    durationTFCustomButton.setTitle(ScheduleTableViewCell.durationDescription(duration: Int(newTimeInterval)), for: .normal)
    durationTFCustomButton.sizeToFit()
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
    let userSettings = (UIApplication.shared.delegate as! AppDelegate).userSettings
    let is24Mode = userSettings.is24Mode
    var durationSinceMidnight = durationSinceMidnight
    if userSettings.is5MinIncrement {
      durationSinceMidnight = ScheduleTableViewCell.roundTo5(integer: durationSinceMidnight)
    }

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
     if String(text.last!) == "M" {
     text.removeLast()
     }
     text = text.lowercased() */
    return text
    //return "ERROR: durationSinceMidnight greater than a day"
  }
  func timeDescriptionA(durationSinceMidnight: Int) -> NSAttributedString {
    let userSettings = (UIApplication.shared.delegate as! AppDelegate).userSettings
    let is24Mode = userSettings.is24Mode

    let text : String = ScheduleTableViewCell.timeDescription(durationSinceMidnight: durationSinceMidnight)
    let attributedString = NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.font : UIFont.monospacedDigitSystemFont(ofSize: startTimeTF.font!.pointSize, weight: .regular)])
    /*
     if durationSinceMidnight < 10 * 3600 || (!is24Mode && durationSinceMidnight >= 13 * 3600) {
     attributedString.setAttributes([NSAttributedStringKey.foregroundColor : UIColor(white: 0.0, alpha: 0.0)], range: NSRange(text.count - 2..<text.count))
     }*/
    //if has AM/PM
    if String(text.last!) == "M" {
      //attributedString.setAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 13)], range: NSRange(text.count - 2..<text.count))
    }
    return attributedString

  }
  static func roundTo5(integer: Int) -> Int {
    return Int((Double(integer / 60) + 2.5) / Double(5).rounded(.down)) * 5 * 60
  }
  static func durationDescription(duration: Int) -> String {
    let userSettings = (UIApplication.shared.delegate as! AppDelegate).userSettings
    var duration = duration
    if userSettings.is5MinIncrement {
      duration = ScheduleTableViewCell.roundTo5(integer: duration)
    }
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
  //iPhone UIKit Sizes: //https://developer.apple.com/library/archive/documentation/DeviceInformation/Reference/iOSDeviceCompatibility/Displays/Displays.html
  //https://www.ios-resolution.com/
  func fitToScreenSize(textField: UITextField) {

    let width = UIScreen.main.bounds.width
    var size = textField.font!.pointSize
    //if is iphone 5/SE
    if width < 330 {
      //if in tutorial or time tf
      if appDelegate.svc.tutorialStep != .done || (textField == startTimeTF || textField == durationTF) {
        size = 12
      } else {
        size = 13
      }
    }
    //if is standard iphone 6/7/8 (width 375)
    else if width < 380 {
      size = 15
      if textField == startTimeTF || textField == durationTF {
        size = 14
      }
    }
    //iphone plus, landscape
    else if width < 1000 {
      size = 16
      if textField == startTimeTF || textField == durationTF {
        size = 15
      }
    }
    //big ipad
    else {
      size = 18
      if textField == startTimeTF || textField == durationTF {
        size = 17
      }
    }

    textField.font = UIFont.systemFont(ofSize: CGFloat(size))
  }
  func setStyle(textField: UITextField) {

    textField.layer.cornerRadius = 7
    textField.layer.borderWidth = 0.5
    textField.layer.borderColor = UIColor.purple.withAlphaComponent(0.2).cgColor


    if(textField == startTimeTF || textField == durationTF) {
      textField.font = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .regular)
    }

  }
  //MARK: Actions

  @IBAction func doubleTap(_ sender: Any, forEvent event: UIEvent) {
    /*
     if event.allTouches!.first!.tapCount == 2 {
     if scheduleItem.duration > userSettings.defaultDuration + 9 * 60 {
     scheduleItem.duration -= 30 * 60
     let newItem: ScheduleItem = ScheduleItem(name: userSettings.defaultName, duration: 30 * 60)
     tvc.scheduleItems.insert(newItem, at: row + 1)
     tvc.update()
     }
     } */
  }
  @IBAction func lockButtonPressed(_ sender: UIButton) {
    if(userSettings.fluxPlus) {
      if (scheduleItem.startTime != nil) {
        scheduleItem.locked = !scheduleItem.locked
        lockButtonUpdated()
      }
    }
    svc.stepLockedComplete()
  }

  func lockButtonUpdated() {
    if scheduleItem.locked {
      startTimeTF.isUserInteractionEnabled = false
      if tvc.testingMode {
        //scheduleItem.taskName = ScheduleTableViewCell.timeDescription(durationSinceMidnight: scheduleItem.startTime!)
        //taskNameTF.text = scheduleItem.taskName
      }
    } else {
      startTimeTF.isUserInteractionEnabled = true
    }
    fitToScreenSize()
    lockButton.setTitle(scheduleItem.locked ? "🔒" : "🌀",for: .normal)
  }
}
