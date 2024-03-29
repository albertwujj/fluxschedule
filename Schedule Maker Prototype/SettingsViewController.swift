//
//  SettingsViewController.swift
//  Schedule Maker Prototype
//
//  Created by Albert Wu on 11/23/17.
//  Copyright © 2017 Old Friend. All rights reserved.
//

import UIKit
import SwiftUI


class SettingsViewController: BaseViewController, UITextFieldDelegate, AccessoryTextFieldDelegate, UIPopoverPresentationControllerDelegate {
  
  @IBOutlet weak var viewStatsButton: UIButton!
  @IBOutlet weak var notificationsSwitch: UISwitch!
  var startTimeTFCustomButton: UIButton!
  var durationTFCustomButton: UIButton!
  var startOfToday = Calendar.current.startOfDay(for: Date())
  @IBOutlet weak var defaultDurationTF: AccessoryTextField!
  @IBOutlet weak var defaultStartTimeTF: AccessoryTextField!
  @IBOutlet weak var tutorialButton: UIButton!
  @IBOutlet weak var incrementsSwitch: UISwitch!
  @IBOutlet weak var timeModeSwitch: UISwitch!
  @IBOutlet weak var topStripe: UIView!
  @IBOutlet weak var compactModeSwitch: UISwitch!
  
  var svc: ScheduleViewController!
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  var userSettings: Settings!
  override func viewDidLoad() {
    super.viewDidLoad()
    svc = appDelegate.svc
    //svc.styleTutButton(button: tutorialButton)
    userSettings = (UIApplication.shared.delegate as! AppDelegate).userSettings
    timeModeSwitch.addTarget(self, action: #selector(timeModeChanged(switchState:)), for: .valueChanged)
    timeModeSwitch.isOn = appDelegate.userSettings.is24Mode
    incrementsSwitch.isOn = appDelegate.userSettings.is5MinIncrement
    notificationsSwitch.isOn = appDelegate.userSettings.notificationsOn
    compactModeSwitch.isOn = appDelegate.userSettings.compactMode
    topStripe.backgroundColor = userSettings.themeColor
    defaultStartTimeTF.accessoryDelegate = self
    defaultDurationTF.accessoryDelegate = self
    defaultStartTimeTF.delegate = self
    defaultDurationTF.delegate = self
    defaultStartTimeTF.text = ScheduleTableViewCell.timeDescription(durationSinceMidnight: userSettings.defaultStartTime)
    
    defaultDurationTF.text = "\(ScheduleTableViewCell.durationDescription(duration: userSettings.defaultDuration))"
    startTimeTFCustomButton = UIButton()
    startTimeTFCustomButton.setTitle(" 88:88 AM  ", for: .normal)
    startTimeTFCustomButton.setTitleColor(.black, for: .normal)
    defaultStartTimeTF.addButtons(customString: nil, customButton: startTimeTFCustomButton)
    durationTFCustomButton = UIButton()
    durationTFCustomButton.setTitle(" 88:88 ", for: .normal)
    durationTFCustomButton.setTitleColor(.black, for: .normal)
    defaultDurationTF.addButtons(customString: nil, customButton: durationTFCustomButton)
    // Do any additional setup after loading the view.
    Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(updateStartOfToday), userInfo: nil, repeats: true)
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  @objc func updateStartOfToday() {
    startOfToday = Calendar.current.startOfDay(for: Date())
  }
  //UIAccessoryTextFieldDelegate Functions
  func textFieldContainerButtonPressed(_ sender: AccessoryTextField) {
    
  }
  
  func textFieldCancelButtonPressed(_ sender: AccessoryTextField) {
    sender.resignFirstResponder()
  }
  
  func textFieldDoneButtonPressed(_ sender: AccessoryTextField) {
    if sender == defaultStartTimeTF {
      appDelegate.userSettings.defaultStartTime = Int((sender.inputView as! UIDatePicker).date.timeIntervalSince(startOfToday))
      sender.text = ScheduleTableViewCell.timeDescription(durationSinceMidnight: appDelegate.userSettings.defaultStartTime)
      appDelegate.saveUserSettings()
      svc.update()
    }
    else if sender == defaultDurationTF {
      appDelegate.userSettings.defaultDuration = Int((sender.inputView as! UIDatePicker).countDownDuration)
      sender.text = "\(ScheduleTableViewCell.durationDescription(duration: userSettings.defaultDuration))"
      appDelegate.saveUserSettings()
      svc.update()
    }
    sender.resignFirstResponder()
  }
  
  
  //MARK: UITextFieldDelegate functions
  func textFieldDidBeginEditing(_ textField: UITextField) {
    if textField == defaultStartTimeTF {
      let datePickerView:UIDatePicker = UIDatePicker()
      datePickerView.datePickerMode = UIDatePickerMode.time
      textField.inputView = datePickerView
      var date: Date!
      
      date = Date(timeInterval: Double(userSettings.defaultStartTime), since: startOfToday)
      
      datePickerView.setDate(date, animated: true)
      startTimeTFCustomButton.setTitle("\(ScheduleTableViewCell.timeDescription(durationSinceMidnight: Int(date.timeIntervalSince(startOfToday))))", for: .normal)
      startTimeTFCustomButton.sizeToFit()
      datePickerView.addTarget(self, action: #selector(datePickerValueChangedStartTime), for: UIControlEvents.valueChanged)
    }
    else if textField == defaultDurationTF {
      let datePickerView:UIDatePicker = UIDatePicker()
      datePickerView.datePickerMode = UIDatePickerMode.countDownTimer
      textField.inputView = datePickerView
      var date: Date!
      date = Date(timeInterval: Double(userSettings.defaultDuration), since: startOfToday)
      datePickerView.setDate(date, animated: true)
      durationTFCustomButton.setTitle("\(ScheduleTableViewCell.durationDescription(duration: Int(date.timeIntervalSince(startOfToday))))", for: .normal)
      durationTFCustomButton.sizeToFit()
      datePickerView.addTarget(self, action: #selector(datePickerValueChangedDuration), for: UIControlEvents.valueChanged)
    }
  }
  @objc func datePickerValueChangedStartTime(sender:UIDatePicker) {
    
    startTimeTFCustomButton.setTitle(ScheduleTableViewCell.timeDescription(durationSinceMidnight: Int(sender.date.timeIntervalSince(startOfToday))), for: .normal)
    startTimeTFCustomButton.sizeToFit()
  }
  @objc func datePickerValueChangedDuration(sender:UIDatePicker) {
    durationTFCustomButton.setTitle(ScheduleTableViewCell.durationDescription(duration: Int(sender.countDownDuration)), for: .normal)
    durationTFCustomButton.sizeToFit()
  }
  
  
  @objc func timeModeChanged(switchState: UISwitch) {
    appDelegate.userSettings.is24Mode = switchState.isOn
  }
  @IBAction func notificationsSwitched(_ sender: UISwitch) {
    if sender.isOn {
      appDelegate.registerForPushNotifications()
      if appDelegate.notifPermitted == false {
        presentAlert(title: "Unable to allow notifications", message: "You must enable notifications for this app in system settings.")
        sender.isOn = false
      }
    }
    appDelegate.userSettings.notificationsOn = sender.isOn
  }
  @IBAction func incrementSwitched(_ sender: UISwitch) {
    appDelegate.userSettings.is5MinIncrement = sender.isOn
    svc.tableViewController.tableView.reloadData()
    
  }
  
  @IBAction func compactModeSwitched(_ sender: UISwitch) {
    let tvc = svc.tableViewController!
    appDelegate.userSettings.compactMode = sender.isOn
    tvc.setSeparator()
    tvc.changeRowHeight()
    tvc.tableView.reloadData()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    if segue.identifier == "statspopover" {
      let vc = segue.destination
      vc.preferredContentSize = CGSize(width:200.0, height:100.0)
      let pc = vc.popoverPresentationController!
      pc.delegate = self
      let button = pc.sourceView!
      pc.sourceRect = CGRect(x:button.bounds.midX, y: button.bounds.maxY,width:0,height:0)
    }
  }
  func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
    return UIModalPresentationStyle.none
  }
  func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
    return true
  }
  @IBAction func backButtonPressed(_ sender: UIButton) {
    dismiss(animated: true, completion: nil)
  }
  
  
  @IBAction func tutorialButtonPressed(_ sender: UIButton) {
    svc.tutorialStep = .welcome
    svc.addTutorial()
    dismiss(animated: true, completion: nil)
  }
  
}
