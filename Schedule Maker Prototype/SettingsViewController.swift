//
//  SettingsViewController.swift
//  Schedule Maker Prototype
//
//  Created by Albert Wu on 11/23/17.
//  Copyright © 2017 Old Friend. All rights reserved.
//

import UIKit


class SettingsViewController: UIViewController, UITextFieldDelegate, AccessoryTextFieldDelegate {
    
    @IBOutlet weak var notificationsSwitch: UISwitch!
    var startTimeTFCustomButton: UIButton!
    var durationTFCustomButton: UIButton!
    var startOfToday = Calendar.current.startOfDay(for: Date())
    @IBOutlet weak var defaultDurationTF: AccessoryTextField!
    @IBOutlet weak var defaultStartTimeTF: AccessoryTextField!
    @IBOutlet weak var incrementsSwitch: UISwitch!
    @IBOutlet weak var timeModeSwitch: UISwitch!
    @IBOutlet weak var topStripe: UIView!
    var svc: ScheduleViewController!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userSettings: Settings!
    override func viewDidLoad() {
        super.viewDidLoad()
        userSettings = (UIApplication.shared.delegate as! AppDelegate).userSettings
        timeModeSwitch.addTarget(self, action: #selector(timeModeChanged(switchState:)), for: .valueChanged)
        timeModeSwitch.isOn = appDelegate.userSettings.is24Mode
        incrementsSwitch.isOn = appDelegate.userSettings.is5MinIncrement
        notificationsSwitch.isOn = appDelegate.userSettings.notificationsOn
        topStripe.backgroundColor = userSettings.themeColor
        defaultStartTimeTF.accessoryDelegate = self
        defaultDurationTF.accessoryDelegate = self
        defaultStartTimeTF.delegate = self
        defaultDurationTF.delegate = self
        defaultStartTimeTF.text = ScheduleTableViewCell.timeDescription(durationSinceMidnight: userSettings.defaultStartTime)
        print("wll settings \(ScheduleTableViewCell.timeDescription(durationSinceMidnight: userSettings.defaultStartTime))")
        defaultDurationTF.text = ScheduleTableViewCell.durationDescription(duration: userSettings.defaultDuration)
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
            sender.text = ScheduleTableViewCell.durationDescription(duration: appDelegate.userSettings.defaultDuration)
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
        appDelegate.userSettings.notificationsOn = sender.isOn
    }
    @IBAction func incrementSwitched(_ sender: UISwitch) {
        appDelegate.userSettings.is5MinIncrement = sender.isOn
        if  appDelegate.userSettings.is5MinIncrement {
            svc.tableViewController.tableView.reloadData()
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}
