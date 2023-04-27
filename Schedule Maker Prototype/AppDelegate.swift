//
//  AppDelegate.swift
//  Schedule Maker Prototype
//
//  Created by Albert Wu on 11/7/17.
//  Copyright © 2017 Old Friend. All rights reserved.
//
//Albert's iPhone 6 Plus device token: 704863c85eed5fdf3a0dfad4b7ed92cb2ea8bceca199ff5e92f3047c3871baf1
import UIKit
import CoreData
import os.log
import UserNotifications
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var tvcLoaded = false
    var window: UIWindow?
    var userSettings: Settings = Settings()
    static let DocumentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    var fullVersionPurchased = true
    var svc: ScheduleViewController!
    var notifPermitted = false
    var sharedDefaults: UserDefaults! = nil
    var recurringTasksTableViewController: RecurringTasksTableViewController?
    var readyToSync = false
    var kvsNotifRecieved = false
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //print(UIDevice.current.modelName)
        
        print("\(UIScreen.main.bounds.width) \(UIScreen.main.bounds.height)")
        
        if let loadedDefaults = UserDefaults(suiteName: "group.9P3FVEPY7V.group.AlbertWu.ScheduleMakerPrototype") {
            sharedDefaults = loadedDefaults
        } else {
            print("UserDefaults BUG")
        }
        print("icloud status: \(isICloudContainerAvailable())")
        sharedDefaults.register(defaults: [:])
        Zephyr.shared = Zephyr()
        Zephyr.sync(keys: [Paths.schedules, Paths.schedulesEdited, Paths.schedule, Paths.streakStats, Paths.tutorialStep, Paths.userSettings], userDefaults: sharedDefaults!)
        Zephyr.addKeysToBeMonitored(keys: Paths.schedules, Paths.schedulesEdited, Paths.schedule, Paths.streakStats, Paths.tutorialStep, Paths.userSettings)
        readyToSync = true
        //syncKVS()



        // Override point for customization after application launch.
        /*
        if (launchOptions != nil)
        {
            // opened from a push notification when the app is closed
            var userInfo = launchOptions[UIApplicationLaunchOptionsKey.localNotification]?
            if (userInfo != nil)
            {
                scheduleViewController.
            }
        }
        */
        if let loadedSettings = loadUserSettings() {
            userSettings = loadedSettings
        }
        self.svc = (self.window!.rootViewController as! ScheduleViewController)
        registerForPushNotifications()
        UNUserNotificationCenter.current().delegate = svc
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("THIS IS THE SCREEN SIZE: \(UIScreen.main.bounds)")

        if let loadedSessCount = loadBasic(key: Paths.sessCount) as? Int {
            for i in [13, 40, 70, 120, 180, 250] {
                if loadedSessCount + 1 == i {
                    requestReview()
                }
            }
            saveBasic(data: loadedSessCount + 1, key: Paths.sessCount)
        } else {
             saveBasic(data: 1, key: Paths.sessCount)
        }
        return true
    }

    func syncKVS() {
        /*
        let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) {
            UIAlertAction in
            overwriteLocal()
        }
        let cancelAction = UIAlertAction(title: "Keep local", style: UIAlertActionStyle.destructive) {
            UIAlertAction in

        }
        svc.presentAlert(title: "iCloud data found", message: "Schedules were found on your iCloud account. Do you want to overwrite your local schedules with the iCloud schedules?", actions: [cancelAction, okAction])
        */

        print("Ready: \(readyToSync), notif: \(kvsNotifRecieved)")
        if readyToSync && kvsNotifRecieved {

            print("synced Zephyr")

            if tvcLoaded {
                print("changed for Zephyr")
                if let savedSchedules = svc.loadSchedules() {
                    svc.schedules = savedSchedules
                }
                if let savedSchedulesEdited = svc.loadSchedulesEdited() {
                    svc.schedulesEdited = savedSchedulesEdited
                }
                if let loadedSettings = loadUserSettings() {
                    userSettings = loadedSettings
                }
                if let loadedTutorialStep = svc.loadTutorialStep() {
                    svc.tutorialStep = loadedTutorialStep
                }
                if let loadedStreakStats = svc.tableViewController.loadStreakStats() {
                    svc.tableViewController.streakStats = loadedStreakStats
                }
                svc.update()
                if svc.tutorialStep == .done {
                    svc.tutorialNextButton.isHidden = true
                }
            }
        }

    }
    func isICloudContainerAvailable()->Bool {
        if let currentToken = FileManager.default.ubiquityIdentityToken {
            return true
        }
        else {
            return false
        }
    }
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Notification permission granted: \(granted)")
            guard granted else { return}
            self.notifPermitted = true
            //self.getNotificationSettings()
            // Create the custom actions for the TIMER_EXPIRED category.
        }
    }
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
        }
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        svc.saveSchedules()
        if let rtvc = recurringTasksTableViewController {
            rtvc.saveRTasks()
        }
        svc.tableViewController.saveScrollPosition()
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        //print("final \((NSUbiquitousKeyValueStore.default.dictionaryRepresentation[Paths.schedulesEdited] as! Set<Int>).count)")
        saveUserSettings()
        if notifPermitted {
            svc.scheduleTaskNotifs(withAction: true)
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.

    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if let savedSchedules = svc.loadSchedules() {
            svc.schedules = savedSchedules
        }
        if let savedSchedulesEdited = svc.loadSchedulesEdited() {
            svc.schedulesEdited = savedSchedulesEdited
        }
        svc.tableViewController.deFlashInstant(itemsToFlash: svc.tableViewController.scheduleItems)
        self.svc.calendar.updateBoundingRect()

        svc.scheduleInactiveNotif()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.

        saveUserSettings()
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Schedule_Maker_Prototype")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    /*
    func saveUserSettings() {
        NSKeyedArchiver.setClassName("ScheduleItem", for: ScheduleItem.self)
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(userSettings, toFile: AppDelegate.DocumentsDirectory.appendingPathComponent(Paths.userSettings).path)
        if isSuccessfulSave {
            os_log("Saving userSettings was successful", log: OSLog.default, type: .debug)
        }
        else {
            os_log("Failed to save userSettings...", log: OSLog.default, type: .debug)
        }
    }
 */
    func saveUserSettings() {
        NSKeyedArchiver.setClassName("Settings", for: Settings.self)
        sharedDefaults.set(NSKeyedArchiver.archivedData(withRootObject: userSettings), forKey: Paths.userSettings)
    }
    
    func loadUserSettings() -> Settings? {
        if let data = sharedDefaults.object(forKey: Paths.userSettings) as? Data {
            NSKeyedUnarchiver.setClass(Settings.self, forClassName: "Settings")
            let unarcher = NSKeyedUnarchiver(forReadingWith: data)
            
            return unarcher.decodeObject(forKey: "root") as? Settings
        }
        return nil
    }
    //MARK: global functions

    func saveBasic(data: Any, key: String) {
        UserDefaults.shared.set(data, forKey: key)
    }
    func loadBasic(key: String) -> Any? {
        return UserDefaults.shared.value(forKey: key)
    }
    @objc func requestReview() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }
    }
}


