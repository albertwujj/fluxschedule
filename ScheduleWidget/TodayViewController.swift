//
//  TodayViewController.swift
//  ScheduleWidget
//
//  Created by Albert Wu on 12/16/17.
//  Copyright © 2017 Old Friend. All rights reserved.
//

import UIKit
import NotificationCenter
import UserNotifications


class TodayViewController: UIViewController, NCWidgetProviding {
    
    
    @IBOutlet weak var extendCurrButton: UIButton!
    @IBOutlet weak var prevTaskLabel: UILabel!
    @IBOutlet weak var currentTaskLabel: UILabel!
    @IBOutlet weak var nextTaskLabel: UILabel!
    @IBOutlet weak var nextTaskTimeLabel: UILabel!
    @IBOutlet weak var prevTaskLockButton: UIButton!
    @IBOutlet weak var currentTaskLockButton: UIButton!
    @IBOutlet weak var nextTaskLockButton: UIButton!
    
    var sharedDefaults: UserDefaults! = nil
    var schedules: [Int:[ScheduleItem]] = [:]
    var scheduleItems: [ScheduleItem] = []
    var currDateInt = 0
    var userSettings = Settings()
    var currScheduleItem: ScheduleItem?
    var nextScheduleItem: ScheduleItem?
    var prevScheduleItem: ScheduleItem?
    var startOfToday = Calendar.current.startOfDay(for: Date())
    override func viewDidLoad() {
        super.viewDidLoad()
        if let loadedDefaults = UserDefaults(suiteName: "group.9P3FVEPY7V.group.AlbertWu.ScheduleMakerPrototype") {
            sharedDefaults = loadedDefaults
        } else {
            print("UserDefaults BUG")
        }
        changeCurrDate()
        if let savedSettings = loadUserSettings() {
            userSettings = savedSettings
        }
        if let savedSchedules = loadSchedules() {
            schedules = savedSchedules
        
        }
        
        if(!userSettings.fluxPlus) {
            extendCurrButton.isHidden = true
        }
        updateDisplay()
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(updateDisplay), userInfo: nil, repeats: true)
    }
    @objc func updateDisplay() {
        if let currSchedule = schedules[currDateInt] {
            scheduleItems = currSchedule
            var prevWasCurr = false
            for (i, scheduleItem) in currSchedule.enumerated()  {
                
                if let startTime = scheduleItem.startTime {
                    let currentTime = getCurrentDurationFromMidnight()
                    
                    if prevWasCurr {
                        nextTaskLabel.text = scheduleItem.taskName
                        nextTaskTimeLabel.text = timeDescription(durationSinceMidnight: scheduleItem.startTime!)
                        nextScheduleItem = scheduleItem
                        nextTaskLockButton.setTitle(scheduleItem.locked ? "🔒" : "🌀", for: .normal)
                        prevWasCurr = false
                        
                    }
                    if startTime <= currentTime && startTime + scheduleItem.duration > currentTime  {
                        currScheduleItem = scheduleItem
                        currentTaskLabel.text = currScheduleItem!.taskName
                        currentTaskLockButton.setTitle(scheduleItem.locked ? "🔒" : "🌀", for: .normal)
                        prevWasCurr = true
                        if i > 0 {
                            prevScheduleItem = currSchedule[i-1];
                            prevTaskLabel.text = prevScheduleItem!.taskName
                            prevTaskLockButton.setTitle(prevScheduleItem!.locked ? "🔒" : "🌀", for: .normal)
                        }
                    }
                }
            }
        }
        prevTaskLockButton.isHidden = prevScheduleItem == nil ? true : false
        currentTaskLockButton.isHidden = currScheduleItem == nil ? true : false
        nextTaskLockButton.isHidden = nextScheduleItem == nil ? true : false
        if(userSettings.fluxPlus) {
            extendCurrButton.isHidden = false
        }
    }
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        
        //self.preferredContentSize = (activeDisplayMode == .compact) ? maxSize : CGSize(width: maxSize.width, height: 300)
        
        if activeDisplayMode == NCWidgetDisplayMode.compact
        {
        }
        else
        {
            self.preferredContentSize = CGSize(width: maxSize.width, height: 560)
        }
    }

    @IBAction func extendTaskButtonPressed(_ sender: UIButton) {
        print("extended")
        if let currItem = currScheduleItem {
            currItem.duration += 5 * 60
        }
        recalculateTimes()
        updateDisplay()
        saveSchedules()
        
    }
    func saveSchedules() {
        NSKeyedArchiver.setClassName("ScheduleItem", for: ScheduleItem.self)
        sharedDefaults.set(NSKeyedArchiver.archivedData(withRootObject: schedules), forKey: Paths.schedules)
    }
    func loadSchedules() -> [Int:[ScheduleItem]]? {
        
        if let data = sharedDefaults.object(forKey: Paths.schedules) as? Data {
            NSKeyedUnarchiver.setClass(ScheduleItem.self, forClassName: "ScheduleItem")
            let unarcher = NSKeyedUnarchiver(forReadingWith: data)
            
            return unarcher.decodeObject(forKey: "root") as? [Int:[ScheduleItem]]
        }
        return nil
    }
    func loadUserSettings() -> Settings? {
        if let data = sharedDefaults.object(forKey: Paths.userSettings) as? Data {
            NSKeyedUnarchiver.setClass(Settings.self, forClassName: "Settings")
            let unarcher = NSKeyedUnarchiver(forReadingWith: data)
            
            return unarcher.decodeObject(forKey: "root") as? Settings
        }
        return nil
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    //just move locked times back to prev, in order :))))
    func recalculateTimes() {
        if scheduleItems.count != 0 {
            if var currStartTime = scheduleItems[0].startTime {
                var origLockedItems: [ScheduleItem] = []
                var i = 0
                while(i < scheduleItems.count){
                    if scheduleItems[i].locked && scheduleItems[i].startTime != nil {
                        origLockedItems.append(scheduleItems[i])
                        scheduleItems.remove(at: i)
                        i -= 1
                    }
                        
                    else {
                        scheduleItems[i].startTime = currStartTime
                        currStartTime += scheduleItems[i].duration
                    }
                    i += 1
                }
                origLockedItems = origLockedItems.sorted(by: { $0.startTime! < $1.startTime! })
                for j in origLockedItems {
                    insertItem(item: j, newStartTime: j.startTime!)
                    recalculateTimesBasic()
                }
                
            }
            
        }
    }
    func recalculateTimesBasic() {
        var currStartTime = 0
        if scheduleItems.count > 0, let st = scheduleItems[0].startTime {
            currStartTime = st
        }
        for i in scheduleItems {
            i.startTime = currStartTime
            currStartTime += i.duration
        }
    }
    
    //inserts an item at the given start time, handling the item in the old spot by the user's insertOption
    func insertItem(item: ScheduleItem, newStartTime: Int) {
        
        let insertOption = userSettings.insertOption
        item.startTime = newStartTime
        
        var prevRow = scheduleItems.count
        //find correct previous item
        swapLoop: while(prevRow >= 0) {
            prevRow -= 1
            if prevRow == -1 || (item.startTime! > scheduleItems[prevRow].startTime! || (item.startTime! == scheduleItems[prevRow].startTime! && insertOption == .extend)) {
                break swapLoop
            }
        }
        //if extending duration, must take "prev prev" item
        if (insertOption == .extend) {
            prevRow -= 1
        }
        scheduleItems.insert(item, at: prevRow + 1)
        let lastRow = scheduleItems.count - 1
        let secondLast = lastRow > 0 ? scheduleItems[lastRow - 1] : nil
        if lastRow > 0 && item.startTime! >= secondLast!.startTime! + secondLast!.duration  {
            secondLast!.duration = item.startTime! - secondLast!.startTime!
        }
        else {
            var splitItem: ScheduleItem!
            //let curr = scheduleItems[i+1]
            var diff = 0
            var prev: ScheduleItem!
            if (prevRow >= 0) {
                prev = scheduleItems[prevRow]
                diff = prev.startTime! + prev.duration - item.startTime!
                prev.duration -= diff
                
                
            }
            
            if(prevRow >= 0 && insertOption == .split && diff != 0) {
                splitItem = ScheduleItem(name: prev.taskName, duration: diff, startTime: item.startTime! + item.duration)
                scheduleItems.insert(splitItem, at: prevRow + 2)
            }
            
        }
        
    }
    func changeCurrDate() {
        currDateInt = dateToHashableInt(date: Date())
        
    }
    func dateToHashableInt(date: Date) -> Int {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let year = calendar.component(.year, from: date)
        //mathematically this will allow consistent conversion from date to int
        return year * 372 + month * 31 + day
    }
    func getCurrentDurationFromMidnight() -> Int {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        return hour * 3600 + minutes * 60 + seconds
    }
    func timeDescription(durationSinceMidnight: Int) -> String {
       
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        let date = startOfToday.addingTimeInterval(Double(durationSinceMidnight))
        var text = formatter.string(from: date)
        if durationSinceMidnight >= 13 * 3600 {
            text = text + " "
        }
       
        if durationSinceMidnight < 10 * 3600 {
            text = text + " "
        }
       
        return text
       
    }
    
    @IBAction func currTaskLockButtonPressed(_ sender: UIButton) {
        let scheduleItem = currScheduleItem!
        if (scheduleItem.startTime != nil) {
            scheduleItem.locked = !scheduleItem.locked
            sender.setTitle(scheduleItem.locked ? "🔒" : "🌀",for: .normal)
            saveSchedules()
        }
    }
    
    
    @IBAction func nextTaskLockButtonPressed(_ sender: UIButton) {
        let scheduleItem = nextScheduleItem!
        if (scheduleItem.startTime != nil) {
            scheduleItem.locked = !scheduleItem.locked
            sender.setTitle(scheduleItem.locked ? "🔒" : "🌀",for: .normal)
            extendCurrButton.isEnabled = !scheduleItem.locked
            saveSchedules()
        }
    }
    func registerCategories() {
        let view = UNNotificationAction(identifier: "view",
                                        title: "View",
                                        options: .foreground)
        let delay = UNNotificationAction(identifier: "delay",
                                         title: "Delay by \(userSettings.notifDelayTime) minutes",
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
            for i in schedules[currDateInt] ?? [] {
                if let startDate = i.startTime {
                    if startDate > getCurrentDurationFromMidnight() {
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
                            schedules[currDateInt]![i - 1].duration += userSettings.notifDelayTime * 60
                           
                        
                            break
                        }
                        if(i == 0) {
                            schedules[currDateInt]![0].startTime! += userSettings.notifDelayTime * 60
                            
                            
                        }
                    }
                    
                }
                updateDisplay()
            default:
                break
            }
        }
        
        // you must call the completion handler when you're done
        completionHandler()
    }
}
