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


class ScheduleViewController: UIViewController, UITextFieldDelegate, AccessoryTextFieldDelegate, UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var tutorialNextButton: UIButton!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userSettings: Settings!
    @IBOutlet weak var iapButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var weekdayLabel: UILabel!
    @IBOutlet weak var dateTextField: AccessoryTextField!
    
    @IBOutlet weak var recurringTasksButton: UIButton!
    @IBOutlet weak var topStripe: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var leftDateButton: UIButton!
    @IBOutlet weak var rightDateButton: UIButton!
    var testingMode = false
    let dayToInt = ["MONDAY": 0, "TUESDAY": 1, "WEDNESDAY": 2, "THURSDAY": 3, "FRIDAY": 4, "SATURDAY": 5, "SUNDAY": 6]
    var schedules : [Int: [ScheduleItem]] = [:]
    var schedulesEdited: Set<Int> = Set<Int>()
    var tableViewController: ScheduleTableViewController!
    var currDateInt = 0
    var selectedDateInt: Int?
    var sharedDefaults: UserDefaults!
    var tutorialStep1: [ScheduleItem]!
    var tutorialStep2: [ScheduleItem]!
    var tutorialStep3: [ScheduleItem]!
    var tutorialStep4: [ScheduleItem]!
    var tutorialStep5: [ScheduleItem]!
    var defaultSchedule: [ScheduleItem]!
    var lockedTasksEnabled = true
    
    var loadedTutorialStep = false
    var loadedSchedules = false
    
    var tutorialStep = 0
    
    override func viewDidLoad() {
        if let loadedDefaults = UserDefaults(suiteName: "group.9P3FVEPY7V.group.AlbertWu.ScheduleMakerPrototype") {
            sharedDefaults = loadedDefaults
        } else {
            print("UserDefaults BUG")
        }
        super.viewDidLoad()
        
        userSettings = appDelegate.userSettings
        
        
        
        defaultSchedule = [ScheduleItem(name: "\(userSettings.defaultName) 1", duration: userSettings.defaultDuration, startTime: userSettings.defaultStartTime)]
        
        topStripe.backgroundColor = appDelegate.userSettings.themeColor
        AppDelegate.changeStatusBarColor(color: appDelegate.userSettings.themeColor)
        recurringTasksButton.setTitle("\u{2630}", for: .normal)
        
        tutorialStep1 = [ScheduleItem(name: "Welcome to Flux!", duration: userSettings.defaultDuration, startTime: userSettings.defaultStartTime), ScheduleItem(name: "These are", duration: userSettings.defaultDuration, startTime: userSettings.defaultStartTime), ScheduleItem(name: "schedule items.", duration: userSettings.defaultDuration, startTime: userSettings.defaultStartTime)]
        tutorialStep2 = [ScheduleItem(name: "Try tapping", duration: userSettings.defaultDuration, startTime: userSettings.defaultStartTime), ScheduleItem(name: "any of", duration: userSettings.defaultDuration), ScheduleItem(name: "the boxes.", duration: userSettings.defaultDuration), ScheduleItem(name: "Left is start time.", duration: userSettings.defaultDuration, startTime: userSettings.defaultStartTime), ScheduleItem(name: "Right is duration.", duration: userSettings.defaultDuration, startTime: userSettings.defaultStartTime)]
        tutorialStep3 = [ScheduleItem(name: "Now, try", duration: userSettings.defaultDuration, startTime: userSettings.defaultStartTime), ScheduleItem(name: "holding the", duration: userSettings.defaultDuration, startTime: userSettings.defaultStartTime), ScheduleItem(name: "blue swirly button", duration: userSettings.defaultDuration, startTime: userSettings.defaultStartTime), ScheduleItem(name: "Can you move us", duration: userSettings.defaultDuration), ScheduleItem(name: "around?", duration: userSettings.defaultDuration)]
         tutorialStep4 = [ScheduleItem(name: "Tap the", duration: userSettings.defaultDuration, startTime: userSettings.defaultStartTime), ScheduleItem(name: "blue swirly button", duration: userSettings.defaultDuration, startTime: userSettings.defaultStartTime), ScheduleItem(name: "to lock a task.", duration: userSettings.defaultDuration, startTime: userSettings.defaultStartTime)]
    
        tutorialStep5 = [ScheduleItem(name: "Morning routine", duration: 45 * 60, startTime: 7 * 3600), ScheduleItem(name: "Check Facebook", duration: 15 * 60), ScheduleItem(name: "Go work", duration: 8 * 3600, locked: userSettings.fluxPlus), ScheduleItem(name: "Donuts with co-workers", duration: 30 * 60, locked: userSettings.fluxPlus), ScheduleItem(name: "Respond to emails", duration: 20 * 60), ScheduleItem(name: "Work on side-project", duration: 45 * 60), ScheduleItem(name: "Pick up Benjamin", duration: userSettings.defaultDuration)]
        
        tutorialNextButton.layer.cornerRadius = 2
        tutorialNextButton.layer.borderWidth = 1
        tutorialNextButton.layer.borderColor = UIColor.blue.cgColor
        tutorialNextButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        if let savedTutorialStep = loadTutorialStep() {
            tutorialStep = savedTutorialStep
        }
        else {
            tutorialStep = 1
        }
        
       print("Tutorial: \(tutorialStep)")
        
        if let savedSchedules = loadSchedules() {
            schedules = savedSchedules
            print("Huh")
        }
        if let savedSchedulesEdited = loadSchedulesEdited() {
            schedulesEdited = savedSchedulesEdited
        }
        
        Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(checkChangeCurrDate), userInfo: nil, repeats: true)
        
        
        containerView.layer.borderColor = appDelegate.userSettings.themeColor.cgColor
        containerView.layer.borderWidth = 0.0;
        changeCurrDate()
        dateTextField.delegate = self
        dateTextField.addButtons(customString: "Today")
        dateTextField.accessoryDelegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(textFieldPressed(_:)))
        weekdayLabel.addGestureRecognizer(tapGesture)
        weekdayLabel.isUserInteractionEnabled = true
        weekdayLabel.textAlignment = .center
        addTutorial()
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(userSettings.fluxPlus) {
            iapButton.isHidden = true
        }
        if(tutorialStep == 4) {
            tableViewController.scheduleItems = tutorialStep4
            tableViewController.updateFromSVC()
            tutorialNextButton.setTitle("Done! Now give me an example.", for: .normal)
            
            tutorialNextButton.layer.borderColor = UIColor.blue.withAlphaComponent(0.1).cgColor
            tutorialNextButton.isEnabled = false
        }
    }
    func addTutorial() {
        
        
        if tutorialStep == 1 {
            tutorialNextButton.isHidden = false
            tutorialNextButton.isEnabled = true
            tutorialNextButton.layer.borderColor = UIColor.blue.cgColor
            tutorialNextButton.setTitle("Next", for: .normal)
        }
        else if tutorialStep == 6 {
            tutorialNextButton.isHidden = false
            tutorialNextButton.isEnabled = false
            tutorialNextButton.layer.borderColor = UIColor.blue.withAlphaComponent(0.1).cgColor
            tutorialNextButton.setTitle("Done!", for: .normal)
        }
        update()
    }
    
    func step3Complete() {
        if tutorialStep == 3 {
            tutorialNextButton.layer.borderColor = UIColor.blue.cgColor
            tutorialNextButton.isEnabled = true
           
        }
    }
    func stepLockedComplete() {
        if tutorialStep == 4 || tutorialStep == 6 {
            
            tutorialNextButton.layer.borderColor = UIColor.blue.cgColor
            tutorialNextButton.isEnabled = true
        }
    }
    //MARK: AccessoryTextFieldDelegate functions
    func textFieldContainerButtonPressed(_ sender: AccessoryTextField) {
        sender.resignFirstResponder()
        if sender === dateTextField {
            changeDate(dateInt: currDateInt)
        }
    }
    func textFieldCancelButtonPressed(_ sender: AccessoryTextField) {
        sender.resignFirstResponder()
    }
    func textFieldDoneButtonPressed(_ sender: AccessoryTextField) {
        if sender === dateTextField {
            sender.resignFirstResponder()
            selectedDateInt = dateToHashableInt(date: (sender.inputView as! UIDatePicker).date)
            update()
        }
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
    

    
    @objc func textFieldPressed(_ sender: UITapGestureRecognizer) {
        dateTextField.becomeFirstResponder()
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
        else if(segue.identifier == "toSettings") {
            let settingsViewController = segue.destination as! SettingsViewController
            settingsViewController.svc = self
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
        //datePickerView.addTarget(self, action: #selector(datePickerValueChanged), for: UIControlEvents.valueChanged)
        
    }
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        selectedDateInt = dateToHashableInt(date: sender.date)
        textFieldShouldReturn(dateTextField)
    }
    
    
    @IBAction func tutorialNextButtonPressed(_ sender: UIButton) {
        if tutorialStep == 1 {
            tutorialStep += 1
            tableViewController.scheduleItems = tutorialStep2
            tableViewController.updateFromSVC()
            sender.setTitle("Next", for: .normal)
            saveTutorialStep()
            
        }
        else if tutorialStep == 2 {
            print("WAT")
            tutorialStep += 1
            tableViewController.scheduleItems = tutorialStep3
            tableViewController.updateFromSVC()
            sender.setTitle("Done!", for: .normal)
            if !userSettings.fluxPlus {
                sender.setTitle("Done! Now give me an example.", for: .normal)
            }
            saveTutorialStep()
            tutorialNextButton.layer.borderColor = UIColor.blue.withAlphaComponent(0.1).cgColor
            sender.isEnabled = false
        }
        else if tutorialStep == 3 {
            if userSettings.fluxPlus {
                tutorialStep += 1
                tableViewController.scheduleItems = tutorialStep4
                tableViewController.updateFromSVC()
                sender.setTitle("Done! Now give me an example.", for: .normal)
                sender.layer.borderColor = UIColor.blue.withAlphaComponent(0.1).cgColor
                sender.isEnabled = false
            }
            else {
                tutorialStep += 2
                tableViewController.scheduleItems = tutorialStep5
                tableViewController.updateFromSVC()
                sender.setTitle("Done. Let me make my own!", for: .normal)
            }
            saveTutorialStep()
        }
        else if tutorialStep == 4 {
            tutorialStep += 1
            tableViewController.scheduleItems = tutorialStep5
            tableViewController.updateFromSVC()
            sender.setTitle("Done. Let me make my own!", for: .normal)
            saveTutorialStep()
        }
        else if tutorialStep == 5 || tutorialStep == 6 {
            tutorialStep = 0
            update()
            saveTutorialStep()
            tutorialNextButton.isHidden = true
        }
    }
    //MARK: Helper functions
    
    //adds recurring tasks to new schedules
    //updates tableViewController
    //updates self
   // FICI SFOUSDFHFDS
    func update() {
        /*
         var oneRTask = false
         if !schedulesEdited.contains(selectedDateInt ?? currDateInt) {
         /*
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
         */
         if(schedules[selectedDateInt ?? currDateInt] == nil || !oneRTask) {
         
         }
         }
         */
        
        if testingMode {
             schedules[selectedDateInt ?? currDateInt] = [ScheduleItem(name: "1", duration: userSettings.defaultDuration, startTime: userSettings.defaultStartTime)]
        }
        
        else if !schedulesEdited.contains(selectedDateInt ?? currDateInt) || schedules[selectedDateInt ?? currDateInt] == nil {
            
            schedules[selectedDateInt ?? currDateInt] = defaultSchedule
             //schedules[selectedDateInt ?? currDateInt] = [ScheduleItem(name: "Morning routine", duration: 45 * 60, startTime: 7 * 3600), ScheduleItem(name: "Check Facebook", duration: 15 * 60), ScheduleItem(name: "Go work", duration: 8 * 3600), ScheduleItem(name: "Donuts with co-workers", duration: 30 * 60), ScheduleItem(name: "Respond to emails", duration: 20 * 60), ScheduleItem(name: "Work on side-project", duration: 45 * 60), ScheduleItem(name: "Pick up Benjamin", duration: userSettings.defaultDuration)]
        }
        
        if tutorialStep != 0 {
            if (tutorialStep == 1) {
                tableViewController.scheduleItems = tutorialStep1
            }
            else if (tutorialStep == 2) {
                tableViewController.scheduleItems = tutorialStep2
            }
            else if (tutorialStep == 3) {
                tableViewController.scheduleItems = tutorialStep3
            }
            else if (tutorialStep == 4 || tutorialStep == 6) {
                tableViewController.scheduleItems = tutorialStep4
            } else if (tutorialStep == 5) {
                tableViewController.scheduleItems = tutorialStep5
            }
        }
        else {
            tableViewController.scheduleItems = schedules[selectedDateInt ?? currDateInt]!
        }
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
    func saveTutorialStep() {
        

        
        if sharedDefaults != nil {
            sharedDefaults.set(tutorialStep + 1, forKey: Paths.tutorialStep)
        }
    }
    
    func loadTutorialStep() -> Int? {
        
        if sharedDefaults != nil {
            if let step = sharedDefaults.value(forKey: Paths.tutorialStep) as? Int
            {
                if step == 1 {
                    return 0
                }
                else if step == 7 {
                    return 6
                }
                else {
                    return 1
                }
                
            }
        }
        return nil
    }
  
    func saveSchedules() {
        if(!loadedSchedules) {
            if let savedSchedules = loadSchedules() {
                schedules = savedSchedules
            }
            if let savedSchedulesEdited = loadSchedulesEdited() {
                schedulesEdited = savedSchedulesEdited
            }
            loadedSchedules = true
        }
        print("save \(schedules[selectedDateInt ?? currDateInt]!.count)")
        if sharedDefaults != nil {
            NSKeyedArchiver.setClassName("ScheduleItem", for: ScheduleItem.self)
            sharedDefaults.set(NSKeyedArchiver.archivedData(withRootObject: schedules), forKey: Paths.schedules)
            sharedDefaults.set(NSKeyedArchiver.archivedData(withRootObject: schedulesEdited), forKey: Paths.schedulesEdited)
        }
    }
    
    func loadSchedules() -> [Int:[ScheduleItem]]? {
    
     
        if sharedDefaults != nil {
            if let data = sharedDefaults.object(forKey: Paths.schedules) as? Data {
                NSKeyedUnarchiver.setClass(ScheduleItem.self, forClassName: "ScheduleItem")
                let unarcher = NSKeyedUnarchiver(forReadingWith: data)
                print("schedulesLoaded")
                return unarcher.decodeObject(forKey: "root") as? [Int:[ScheduleItem]]
            }
        }
        else {
            print("tried to access default EARLY")
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
        if(userSettings.notificationsOn) {
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
            if(userSettings.fluxPlus) {
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
        }
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let savedSchedules = loadSchedules() {
            schedules = savedSchedules
        }
        if let savedSchedulesEdited = loadSchedulesEdited() {
            schedulesEdited = savedSchedulesEdited
        }
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
                schedulesEdited.insert(selectedDateInt ?? currDateInt)
                saveSchedules()
                
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
    func changeDate(dateInt: Int) {
        selectedDateInt = dateInt
        update()
    }
    
    @IBAction func testingModeButtonPressed(_ sender: UIButton) {
        testingMode = !testingMode
        tableViewController.testingMode = testingMode
        if testingMode {
            sender.backgroundColor = .red
            tutorialStep = 1
            addTutorial()
            update()
        }
        else {
            sender.backgroundColor = .blue
        }
        
    }
}
