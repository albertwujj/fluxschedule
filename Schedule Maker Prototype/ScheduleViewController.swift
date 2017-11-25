//
//  ScheduleViewController.swift
//  Schedule Maker Prototype
//
//  Created by Albert Wu on 11/10/17.
//  Copyright © 2017 Old Friend. All rights reserved.
//

import UIKit
import os.log
import Foundation

class ScheduleViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var weekdayLabel: UILabel!
    @IBOutlet weak var dateTextField: UITextField!
    
    var schedules : [Int: [ScheduleItem]] = [:]
    var tableViewController: ScheduleTableViewController!
    
    var currDateInt = 0
    var selectedDateInt: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(checkChangeCurrDate), userInfo: nil, repeats: true)
        
        
        if let savedScheduleDates = loadScheduleDates() {
            for i in savedScheduleDates {
                schedules[i] = loadSchedule(date: i)
            }
            
        }
        /*
        if let savedSchedules = loadSchedulesData() {
            schedules = savedSchedules
        }
        */
        currDateInt = dateToHashableInt(date: Date())
        update()
        dateTextField.delegate = self
        // Do any additional setup after loading the view.
    }
  
    @objc func checkChangeCurrDate() {
        if dateToHashableInt(date: Date()) != currDateInt {
            changeCurrDate()
        }
    }
    func changeCurrDate() {
        currDateInt = dateToHashableInt(date: Date())
        update()
    }
    func weekday(date: Date) -> String  {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: date).capitalized
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
        
        if(segue.identifier == "EmbeddedTable") {
            tableViewController = segue.destination as! ScheduleTableViewController
            tableViewController.scheduleViewController = self
            tableViewController.currDateInt = currDateInt
            tableViewController.update()
            /*
             if let sDate = selectedDate {
             selectedDateInt = dateToHashableInt(date: sDate)
             }
             else {
             selectedDateInt = nil
             }
             */
            
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
        tableViewController.update()
    }
    
    //MARK: Input handling
    @IBAction func startTimeEditing(_ sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.date
        sender.inputView = datePickerView
        datePickerView.setDate(intToDate(int: selectedDateInt ?? currDateInt), animated: true)
        datePickerView.addTarget(self, action: #selector(datePickerValueChanged), for: UIControlEvents.valueChanged)
        
    }
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        selectedDateInt = dateToHashableInt(date: sender.date)
        update()
        textFieldShouldReturn(dateTextField)
    }
    
    //MARK: Helper functions
    
    func update() {
        
        if schedules[selectedDateInt ?? currDateInt] == nil {
            schedules[selectedDateInt ?? currDateInt] = [ScheduleItem(name: "Task", duration: 30 * 60)]
        }
        tableViewController.scheduleItems = schedules[selectedDateInt ?? currDateInt]!
        tableViewController.currDateInt = selectedDateInt ?? currDateInt
        tableViewController.update()
        dateTextField.text = dateDescription(date: intToDate(int: selectedDateInt ?? currDateInt))
        weekdayLabel.text = weekday(date: intToDate(int: selectedDateInt ?? currDateInt))
        //dateTextField.text = intDateDescription(int: selectedDateInt ?? currDateInt)
        saveScheduleDates()
        saveSchedules()
        saveSchedulesData()
    }
    func dateDescription(date: Date) -> String {
        let formatter = DateFormatter()

        formatter.dateStyle = .medium
        formatter.timeStyle = .none
     
        return formatter.string(from: date)
    }
    func dateToHashableInt(date: Date) -> Int {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let year = calendar.component(.year, from: date)
        //mathematically this will allow consistent conversion from date to int
        return year * 372 + month * 31 + day
    }
    func intToDate(int: Int) -> Date {
        var intMutable = int
        var dC = DateComponents()
        dC.year = intMutable / 372
        intMutable = intMutable % 372
        dC.month = intMutable / 31
        intMutable = intMutable % 31
        dC.day = intMutable
        return Calendar.current.date(from: dC)!
    }

    func intDateDescription(int: Int) -> String {
        var intMutable = int
        let year = intMutable / 372
        intMutable = intMutable % 372
        let month = intMutable / 31
        intMutable = intMutable % 31
        let day = intMutable
        return "\(month)/\(day)/\(year)"
    }
    //MARK: Persist Data
    /*
    func saveSchedules() {
        let savableSchedules = NSMutableDictionary()
        for i in schedules.allKeys {
            savableSchedules.setObject(Schedule(scheduleItems: schedules.object(forKey: i) as! [ScheduleItem]), forKey: i as! NSCopying)
        }
        
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(savableSchedules, toFile: AppDelegate.DocumentsDirectory.appendingPathComponent(Paths.schedules).path)
        if isSuccessfulSave {
            os_log("Saving schedules was successful", log: OSLog.default, type: .debug)
        }
        else {
            os_log("Failed to save schedules...", log: OSLog.default, type: .debug)
        }
    }
    func loadSchedules() -> NSMutableDictionary?{
      
        

        if let savedSchedules = NSKeyedUnarchiver.unarchiveObject(withFile: AppDelegate.DocumentsDirectory.appendingPathComponent(Paths.schedules).path) as? NSMutableDictionary {
            let ret = NSMutableDictionary()
            for i in savedSchedules.allKeys {
                ret.setObject((savedSchedules.object(forKey: i) as! Schedule).scheduleItems, forKey: i as! NSCopying)
            }
            return ret
        }
        else {
            return nil
        }
    }
    */
    
    func saveSchedules() {
        for i in schedules.keys {
            let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(schedules[i]!, toFile: AppDelegate.DocumentsDirectory.appendingPathComponent(Paths.schedule + String(i)).path)
            if isSuccessfulSave {
                os_log("Saving schedule was successful", log: OSLog.default, type: .debug)
            }
            else {
                os_log("Failed to save schedule...", log: OSLog.default, type: .debug)
            }
        }
    }
    func saveSchedule(date: Int, scheduleItems:[ScheduleItem]) {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(scheduleItems, toFile: AppDelegate.DocumentsDirectory.appendingPathComponent(Paths.schedule + String(date)).path)
        if isSuccessfulSave {
            os_log("Saving schedule was successful", log: OSLog.default, type: .debug)
        }
        else {
            os_log("Failed to save schedule...", log: OSLog.default, type: .debug)
        }
    }
    func loadSchedule(date: Int) -> [ScheduleItem]?{
        
        return NSKeyedUnarchiver.unarchiveObject(withFile: AppDelegate.DocumentsDirectory.appendingPathComponent(Paths.schedule + String(date)).path) as? [ScheduleItem]
    }
    
    func saveScheduleDates() {
        var arr: [Int] = []
        for i in schedules.keys {
            arr.append(i)
        }
        
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(arr, toFile: AppDelegate.DocumentsDirectory.appendingPathComponent(Paths.scheduleDates).path)
        if isSuccessfulSave {
            os_log("Saving scheduleDates was successful", log: OSLog.default, type: .debug)
        }
        else {
            os_log("Failed to save scheduleDates...", log: OSLog.default, type: .debug)
        }
    }
    func loadScheduleDates() -> [Int]?{
        
        return NSKeyedUnarchiver.unarchiveObject(withFile: AppDelegate.DocumentsDirectory.appendingPathComponent(Paths.scheduleDates).path) as? [Int]
    }
   
 
    @IBAction func addButtonPressed(_ sender: UIButton) {
        tableViewController!.addButtonPressed()
    
        
    }
    
   
    func loadSchedulesData() -> [Int: [ScheduleItem]]?{
        return (NSKeyedUnarchiver.unarchiveObject(withFile: AppDelegate.DocumentsDirectory.appendingPathComponent(Paths.schedules).path) as! Schedule).s
    }
    
    func saveSchedulesData() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(Schedule(s: schedules), toFile: AppDelegate.DocumentsDirectory.appendingPathComponent(Paths.schedules).path)
        if isSuccessfulSave {
            os_log("Saving schedules was successful", log: OSLog.default, type: .debug)
        }
        else {
            os_log("Failed to save schedules...", log: OSLog.default, type: .debug)
        }
    }
}
