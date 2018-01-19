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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var userSettings: Settings = Settings()
    static let DocumentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    var fullVersionPurchased = true
    var scheduleViewController: ScheduleViewController!
    var notifPermitted = false
    var sharedDefaults: UserDefaults! = nil
    var recurringTasksTableViewController: RecurringTasksTableViewController?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        sharedDefaults = UserDefaults(suiteName: "group.9P3FVEPY7V.group.AlbertWu.ScheduleMakerPrototype")!
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
        
        registerForPushNotifications()
        self.scheduleViewController = self.window!.rootViewController?.childViewControllers.first as! ScheduleViewController
        UNUserNotificationCenter.current().delegate = scheduleViewController
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("THIS IS THE SCREEN SIZE: \(UIScreen.main.bounds)")
        return true
    }
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            guard granted else { return }
            self.notifPermitted = granted
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
        scheduleViewController.saveSchedules()
        if let rtvc = recurringTasksTableViewController {
            rtvc.saveRTasks()
        }
        scheduleViewController.tableViewController.saveScrollPosition()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        //scheduleTaskNotif()
        if notifPermitted {
            scheduleViewController.scheduleTaskNotifs(withAction: false)
        }
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if let newSchedule = scheduleViewController.loadSchedules() {
            scheduleViewController.schedules = newSchedule
            scheduleViewController.update()
        }
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
    static func changeStatusBarColor(color: UIColor) {
        //Status bar style and visibility
        UIApplication.shared.statusBarStyle = .lightContent
        
        //Change status bar color
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = color
        }
    }
    
}

