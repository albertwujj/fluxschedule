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
import UserNotifications


class ScheduleViewController: UIViewController, UITextFieldDelegate, UNUserNotificationCenterDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var weekdayLabel: UILabel!
    @IBOutlet weak var dateTextField: UITextField!
    
    @IBOutlet weak var recurringTasksButton: UIButton!
    @IBOutlet weak var topStripe: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var leftDateButton: UIButton!
    @IBOutlet weak var rightDateButton: UIButton!
    
    let dayToInt = ["MONDAY": 0, "TUESDAY": 1, "WEDNESDAY": 2, "THURSDAY": 3, "FRIDAY": 4, "SATURDAY": 5, "SUNDAY": 6]
    var schedules : [Int: [ScheduleItem]] = [:]
    var schedulesEdited: Set<Int> = Set<Int>()
    var tableViewController: ScheduleTableViewController!
    
    var currDateInt = 0
    var selectedDateInt: Int?
    var sharedDefaults: UserDefaults!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topStripe.backgroundColor = appDelegate.userSettings.themeColor
        AppDelegate.changeStatusBarColor(color: appDelegate.userSettings.themeColor)
        recurringTasksButton.setTitle("\u{2630}", for: .normal)
        sharedDefaults = UserDefaults.init(suiteName: "group.AlbertWu.ScheduleMakerPrototype")
        if let savedSchedules = loadSchedules() {
            schedules = savedSchedules
        }
        if let savedSchedulesEdited = loadSchedulesEdited() {
            schedulesEdited = savedSchedulesEdited
        }
        
        Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(checkChangeCurrDate), userInfo: nil, repeats: true)
        //loadSavedData()
        
        containerView.layer.borderColor = appDelegate.userSettings.themeColor.cgColor
        containerView.layer.borderWidth = 0.0;
        
        /*
        if let savedSchedules = loadSchedulesData() {
            schedules = savedSchedules
        }
        */
        changeCurrDate()
        dateTextField.delegate = self
       
        // Do any additional setup after loading the view.
    }
    /*
    private func loadSavedData() {
        if let savedScheduleDates = loadScheduleDates() {
            for i in savedScheduleDates {
                schedules[i] = loadSchedule(date: i)
            }
        }
    }
 */
    @objc func checkChangeCurrDate() {
        if dateToHashableInt(date: Date()) != currDateInt {
            changeCurrDate()
        }
    }
    func changeCurrDate() {
        currDateInt = dateToHashableInt(date: Date())
        update()
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
        update()
        return false
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
        textFieldShouldReturn(dateTextField)
    }
    
    //MARK: Helper functions
    
    //adds recurring tasks to new schedules
    //updates tableViewController
    //updates self
    func update() {
        var oneRTask = false
        if !schedulesEdited.contains(selectedDateInt ?? currDateInt) {
            if let rTasks = RecurringTasksTableViewController.loadRTasks() {
                var scheduleItems:[ScheduleItem] = []
                for rTask in rTasks {
                    if rTask.startTime != nil {
                        let currDayInt = dayToInt[weekday(date: intToDate(int: selectedDateInt ?? currDateInt))]!
                        if rTask.recurDays!.contains(currDayInt)  {
                            oneRTask = true
                            scheduleItems.append(rTask)
                        }
                    }
                }
                schedules[selectedDateInt ?? currDateInt] = scheduleItems
            }
            
            if(schedules[selectedDateInt ?? currDateInt] == nil || !oneRTask) {
                schedules[selectedDateInt ?? currDateInt] = [ScheduleItem(name: "", duration: 30 * 60)]
            }
        }
        tableViewController.scheduleItems = schedules[selectedDateInt ?? currDateInt]!
        tableViewController.currDateInt = selectedDateInt ?? currDateInt
        tableViewController.updateFromSVC()
        let date = intToDate(int: selectedDateInt ?? currDateInt)
        dateTextField.text = dateDescription(date: intToDate(int: selectedDateInt ?? currDateInt))
        weekdayLabel.text = "\(date.format(format: "EEEE")), \(date.format(format: "MMM")) \(date.format(format: "d"))"
        //dateTextField.text = intDateDescription(int: selectedDateInt ?? currDateInt)
        //saveScheduleDates()
        saveSchedules()
        //saveSchedulesData()
    }
    func currentScheduleUpdated() {
        schedulesEdited.insert(selectedDateInt ?? currDateInt)
        print(intDateDescription(int: selectedDateInt ?? currDateInt))
    }
    
    func weekday(date: Date) -> String  {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: date).uppercased()
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
    
    /*
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
    
   func loadScheduleDates() -> [Int]?{
        
        return NSKeyedUnarchiver.unarchiveObject(withFile: AppDelegate.DocumentsDirectory.appendingPathComponent(Paths.scheduleDates).path) as? [Int]
    }
 */
    func saveSchedules() {
        NSKeyedArchiver.setClassName("ScheduleItem", for: ScheduleItem.self)
        sharedDefaults.set(NSKeyedArchiver.archivedData(withRootObject: schedules), forKey: Paths.schedules)
        sharedDefaults.set(NSKeyedArchiver.archivedData(withRootObject: schedulesEdited), forKey: Paths.schedulesEdited)
        print("schedulesSaved")
    }
    
    func loadSchedules() -> [Int:[ScheduleItem]]? {
        if let data = sharedDefaults.object(forKey: Paths.schedules) as? Data {
            NSKeyedUnarchiver.setClass(ScheduleItem.self, forClassName: "ScheduleItem")
            let unarcher = NSKeyedUnarchiver(forReadingWith: data)
            
            return unarcher.decodeObject(forKey: "root") as? [Int:[ScheduleItem]]
        }
        return nil
    }
    func loadSchedulesEdited() -> Set<Int>? {
        if let data = sharedDefaults.object(forKey: Paths.schedulesEdited) as? Data {
            let unarcher = NSKeyedUnarchiver(forReadingWith: data)
            return unarcher.decodeObject(forKey: "root") as? Set<Int>
        }
        return nil
    }
 
    @IBAction func addButtonPressed(_ sender: UIButton) {
        tableViewController!.addButtonPressed()
    
        
    }
    
   /*
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
 */
    func registerCategories() {
        let view = UNNotificationAction(identifier: "view",
                                        title: "View",
                                        options: .foreground)
        let delay = UNNotificationAction(identifier: "delay",
                                         title: "Delay by \(appDelegate.userSettings.notifDelayTime) minutes",
            options: UNNotificationActionOptions(rawValue: 0))
        
        let taskNoAction = UNNotificationCategory(identifier: "taskNoAction",
                                                      actions: [],
                                                      intentIdentifiers: [],
                                                      options: UNNotificationCategoryOptions(rawValue: 0))
        let taskWithAction = UNNotificationCategory(identifier: "taskWithAction",
                                                      actions: [delay],
                                                      intentIdentifiers: [],
                                                      options: UNNotificationCategoryOptions(rawValue: 0))
        let center = UNUserNotificationCenter.current()

        center.setNotificationCategories([taskNoAction, taskWithAction])
    }
    @objc func scheduleTaskNotifs(withAction: Bool) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        registerCategories()
        let center = UNUserNotificationCenter.current()
        let inactiveTrigger = UNTimeIntervalNotificationTrigger(timeInterval: (48*60*60), repeats: false)
        let inactiveContent = UNMutableNotificationContent()
        inactiveContent.title = "You haven't used the app for 48 hours"
        inactiveContent.body = "You've been gone for 48 hours. Wanna get back on a schedule?"
        inactiveContent.categoryIdentifier = withAction ? "taskWithAction": "taskNoAction"
        inactiveContent.sound = UNNotificationSound.default()
        
        let inactiveRequest = UNNotificationRequest(identifier: UUID().uuidString, content: inactiveContent, trigger: inactiveTrigger)
        center.add(inactiveRequest)
        for i in schedules[currDateInt] ?? [] {
            if let startDate = i.startTime {
                if startDate > tableViewController.getCurrentDurationFromMidnight() {
                    let content = UNMutableNotificationContent()
                    content.title = "Time for: \(i.taskName)"
                    content.body = "Leggo!"
                    content.categoryIdentifier = withAction ? "taskWithAction": "taskNoAction"
                    content.userInfo = ["notifDate": startDate]
                    content.sound = UNNotificationSound.default()
                    
                    var dateComponents = DateComponents()
                    dateComponents.hour = startDate / 3600
                    dateComponents.minute = (startDate % 3600) / 60
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                    
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    center.add(request)
                }
            }
        }
        
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // pull out the buried userInfo dictionary
        self.currDateInt = dateToHashableInt(date: Date())
        let userInfo = response.notification.request.content.userInfo
        
        if let notifDate = userInfo["notifDate"] as? Int {
            print("notifDate received: \(notifDate)")
            
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                
                print("Default identifier")
            
            case "delay":
                print("pls")
                // the user tapped our "show more info…" button
                print("delay task")
                
                saveSchedules()
                
                for i in 0..<(schedules[currDateInt] ?? []).count {
                    print("Hey: \(i)")
                    if schedules[currDateInt]![i].startTime != nil && schedules[currDateInt]![i].startTime! == notifDate {
                        
                        if(i > 0) {
                            schedules[currDateInt]![i - 1].duration += appDelegate.userSettings.notifDelayTime * 60
                        
                            if(selectedDateInt ?? currDateInt == currDateInt) {
                                update()
                        
                            }
                            break
                        }
                        if(i == 0) {
                            schedules[currDateInt]![0].startTime! += appDelegate.userSettings.notifDelayTime * 60
                            if(selectedDateInt ?? currDateInt == currDateInt) {
                                update()
                        
                            }
                        }
                    }
                }
            default:
                break
            }
        }
        
        // you must call the completion handler when you're done
        completionHandler()
    }
    @IBAction func leftDateButtonPressed(_ sender: UIButton) {
        changeDate(change: -1)
    }
    
    @IBAction func rightDateButtonPressed(_ sender: UIButton) {
        changeDate(change: 1)
    }
    func changeDate(change: Int) {
        if selectedDateInt != nil {
            selectedDateInt! += change
        } else {
            selectedDateInt = currDateInt + change
        }
        update()
        
    }
}
