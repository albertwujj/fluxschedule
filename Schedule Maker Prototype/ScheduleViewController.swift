//
//  ScheduleViewController.swift
//  Schedule Maker Prototype
//
//  Created by Albert Wu on 11/10/17.
//  Copyright © 2017 Old Friend. All rights reserved.
//

import UIKit
import SwiftUI
import StoreKit
import os.log
import Foundation
import UserNotifications

enum Tut:Int {
    case done, welcome, lock, drag, delete
    init(_ rawValue: Int) {
        self = Tut(rawValue: rawValue) ?? .done
    }
}

class SettingsViewObservable: ObservableObject {
  @Published var isCompactMode: Bool! = false
  @Published var is5MinIncrement: Bool! = false
  @Published var defaultStartTime: Date! = Date(timeIntervalSinceReferenceDate: 3600.0 * 6.0)
  @Published var defaultDuration: TimeInterval! = 1800
  var onToggleCompact: (()->Void)! = {}
  var onToggle5MinIncrement: (()->Void)! = {}
  var onChangeStartTime: (()->Void)! = {}
  var onChangeDuration: (()->Void)! = {}
  var dismiss: (()->Void)! = {}
}



class ScheduleViewController: BaseViewController, UITextFieldDelegate, AccessoryTextFieldDelegate, UNUserNotificationCenterDelegate, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {


    @IBSegueAction func settingsButtonPressed(_ coder: NSCoder) -> UIViewController? {
      let observable = SettingsViewObservable()
      observable.isCompactMode = userSettings.compactMode
      observable.onToggleCompact = { [self, observable] in
        self.appDelegate.userSettings.compactMode = observable.isCompactMode
      }
      observable.is5MinIncrement = userSettings.is5MinIncrement
      observable.onToggle5MinIncrement = { [self, observable] in
        self.appDelegate.userSettings.is5MinIncrement = observable.is5MinIncrement
      }

      observable.defaultStartTime = Date.init(timeIntervalSinceReferenceDate: TimeInterval(userSettings.defaultStartTime))
      observable.onChangeStartTime = { [self, observable] in
        self.appDelegate.userSettings.defaultStartTime = Int(observable.defaultStartTime.timeIntervalSinceReferenceDate)
      }
      observable.defaultDuration = TimeInterval(userSettings.defaultDuration)
      observable.onChangeDuration = { [self, observable] in
        self.appDelegate.userSettings.defaultDuration = Int(observable.defaultDuration)
      }

      let ret = UIHostingController(coder: coder, rootView: SwiftUISettingsView(observable: observable))
      observable.dismiss = { [ret] in
        ret!.dismiss(animated: true, completion: nil)
        self.tableViewController.setSeparator()
        self.tableViewController.changeRowHeight()
        self.tableViewController.tableView.reloadData()
        self.update()
      }
      return ret
  }

    fileprivate let gregorian = Calendar.current
    fileprivate let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    var statusBarShouldBeHidden:Bool = false {
        didSet {
            //UIApplication.shared.isStatusBarHidden = statusBarShouldBeHidden
            UIView.animate(withDuration: 0.7) { () -> Void in
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    override var prefersStatusBarHidden: Bool {
        return statusBarShouldBeHidden
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation{
        return .slide
    }

    @IBOutlet weak var tutorialHeader: UIView!
    
    @IBOutlet weak var tutInstructions: UILabel!
    @IBOutlet weak var fsCalendarButton: UIButton!
    @IBOutlet weak var calendarHeader: UIView!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarTodayButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tutorialBackButton: UIButton!
    @IBOutlet weak var tutorialNextButton: UIButton!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userSettings: Settings!
    @IBOutlet weak var iapButton: UIButton!
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
    var tutorialStepWelcome: [ScheduleItem]!
    var tutorialStepTap: [ScheduleItem]!
    var tutorialStepLock: [ScheduleItem]!
    var tutorialStepDrag: [ScheduleItem]!
    var tutorialStepExample: [ScheduleItem]!
    var tutorialStepDelete: [ScheduleItem]!
    var defaultSchedule: [ScheduleItem]!

    let tutItemsWelcome: [ScheduleItem] = []
    let tutItemsLock = [ScheduleItem(name: "Important Meeting", duration: 45 * 60, startTime: 14 * 3600)]
    let tutItemsDrag = [ScheduleItem(name: "Relax", duration: 30 * 60, startTime: 19 * 3600), ScheduleItem(name: "Work", duration: 35 * 60)]
    let tutItemsDelete = [ScheduleItem(name: "Waste time", duration: 30 * 60, startTime: 21 * 3600)]
    let tutItemsDouble = [ScheduleItem(name: "Morning Routine", duration: 7 * 3600, startTime: 7 * 3600), ScheduleItem(name: "Important Meeting", duration: 2 * 3600, locked: true)]

    var lockedTasksEnabled = true

    var loadedTutorialStep = false
    var loadedSchedules = false

    var hasFinishedTutorial = false

    var tutorialStep: Tut = .done


    @IBOutlet weak var streakLabel: UILabel!


    @IBOutlet weak var tutHeaderTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var topStripeTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewTopConstraintTut: NSLayoutConstraint!
    @IBOutlet weak var containerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var calendarHeaderHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var calendarBottomSpaceConstraint: NSLayoutConstraint!
    override func viewDidLoad() {

        if let loadedDefaults = UserDefaults(suiteName: "group.9P3FVEPY7V.group.AlbertWu.ScheduleMakerPrototype") {
            sharedDefaults = loadedDefaults
        } else {
            print("UserDefaults BUG")
        }
        super.viewDidLoad()

        print(String(calculateDailyStreak(tableViewController.streakStats)))
        streakLabel.text = String(calculateDailyStreak(tableViewController.streakStats))
        calendar.allowsMultipleSelection = false
        calendar.isHidden = true
        calendar.placeholderType = .fillHeadTail
        userSettings = appDelegate.userSettings

        
        styleTutButton(button: tutorialNextButton)
        styleTutButton(button: tutorialBackButton)
        styleAddButtonPlus()

        topStripe.backgroundColor = appDelegate.userSettings.themeColor
       
        recurringTasksButton.setTitle("\u{2630}", for: .normal)
        /*
        tutorialStepWelcome = [ScheduleItem(name: "Welcome to Flux!", duration: userSettings.defaultDuration, startTime: userSettings.defaultStartTime), ScheduleItem(name: "These are", duration: userSettings.defaultDuration, startTime: userSettings.defaultStartTime), ScheduleItem(name: "schedule items.", duration: userSettings.defaultDuration, startTime: userSettings.defaultStartTime)]
        tutorialStepTap = [ScheduleItem(name: "Try tapping", duration: userSettings.defaultDuration, startTime: userSettings.defaultStartTime), ScheduleItem(name: "any of", duration: userSettings.defaultDuration), ScheduleItem(name: "the boxes.", duration: userSettings.defaultDuration), ScheduleItem(name: "Left is start time.", duration: userSettings.defaultDuration, startTime: userSettings.defaultStartTime), ScheduleItem(name: "Right is duration.", duration: userSettings.defaultDuration, startTime: userSettings.defaultStartTime)]
        tutorialStepDelete = [ScheduleItem(name: "Swipe", duration: userSettings.defaultDuration, startTime: userSettings.defaultStartTime), ScheduleItem(name: "left", duration: userSettings.defaultDuration), ScheduleItem(name: "on an item", duration: userSettings.defaultDuration), ScheduleItem(name: "to delete it.", duration: userSettings.defaultDuration, startTime: userSettings.defaultStartTime)]
        tutorialStepLock = [ScheduleItem(name: "Tap the", duration: userSettings.defaultDuration, startTime: userSettings.defaultStartTime), ScheduleItem(name: "blue swirly button", duration: userSettings.defaultDuration, startTime: userSettings.defaultStartTime), ScheduleItem(name: "to lock a task.", duration: userSettings.defaultDuration, startTime: userSettings.defaultStartTime)]
        tutorialStepDrag = [ScheduleItem(name: "Now, try", duration: userSettings.defaultDuration, startTime: userSettings.defaultStartTime), ScheduleItem(name: "holding the", duration: userSettings.defaultDuration, startTime: userSettings.defaultStartTime), ScheduleItem(name: "blue swirly button", duration: userSettings.defaultDuration, startTime: userSettings.defaultStartTime), ScheduleItem(name: "Can you drag us", duration: userSettings.defaultDuration), ScheduleItem(name: "around?", duration: userSettings.defaultDuration)]
        tutorialStepExample = [ScheduleItem(name: "Morning routine", duration: 45 * 60, startTime: 7 * 3600), ScheduleItem(name: "Inspect Instagram", duration: 15 * 60), ScheduleItem(name: "Go work", duration: 8 * 3600, locked: userSettings.fluxPlus), ScheduleItem(name: "Donuts with co-workers", duration: 30 * 60, locked: userSettings.fluxPlus), ScheduleItem(name: "Respond to emails", duration: 20 * 60), ScheduleItem(name: "Work on side-project", duration: 45 * 60), ScheduleItem(name: "Pick up Benjamin", duration: userSettings.defaultDuration)]
        */

        if let savedTutorialStep = loadTutorialStep() {
            tutorialStep = savedTutorialStep
        }
        else {
            tutorialStep = Tut(1)
        }

        if let savedSchedules = loadSchedules() {
            schedules = savedSchedules
        }
        if let savedSchedulesEdited = loadSchedulesEdited() {
            schedulesEdited = savedSchedulesEdited
        }
        if let loadedTutFinished = loadBasic(key: Paths.hasFinishedTutorial) as? Bool {
            hasFinishedTutorial = loadedTutFinished
        }
        Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(checkChangeCurrDate), userInfo: nil, repeats: true)

        containerView.layer.borderColor = appDelegate.userSettings.themeColor.cgColor
        containerView.layer.borderWidth = 0.0;
        /*
        tutorialHeader.layer.shadowColor = UIColor.black.cgColor
        tutorialHeader.layer.shadowOpacity = 0.7
        tutorialHeader.layer.shadowOffset = CGSize(width: 0, height: 0)
        tutorialHeader.layer.shadowRadius = 4
        */
        calendar.layer.shadowColor = UIColor.black.cgColor
        calendar.layer.shadowOpacity = 0.7
        calendar.layer.shadowOffset = CGSize(width: 0, height: 0)
        calendar.layer.shadowRadius = 5


        changeCurrDate()
        dateTextField.delegate = self
        dateTextField.accessoryDelegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(textFieldPressed(_:)))
        weekdayLabel.addGestureRecognizer(tapGesture)
        weekdayLabel.isUserInteractionEnabled = true
        weekdayLabel.textAlignment = .center
        calendarHeader.layer.borderColor = UIColor.clear.cgColor
        checkAddTutorial()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(userSettings.fluxPlus) {
            iapButton.isHidden = true
        }
    }


    func checkAddTutorial() {
        if tutorialStep == Tut(1) {
            addTutorial()
        } else {
            removeTutorial()
        }
    }
    func addTutorial() {
        setTutorial(step: tutorialStep)
        tutorialHeader.isHidden = false
        containerViewTopConstraint.isActive = false
        containerViewTopConstraintTut.isActive = true
        topStripe.isHidden = true
        statusBarShouldBeHidden = true

        disableAll()
    }
    func adjustContainerView() {
        containerViewTopConstraint.constant = tutorialHeader.bounds.size.height + 4
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: { (finished) -> Void in

        })
    }
    func removeTutorial() {
        containerViewTopConstraint.constant = 0
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: { (finished) -> Void in

        })
        tutorialHeader.isHidden = true
        containerViewTopConstraint.isActive = true
        containerViewTopConstraintTut.isActive = false
        tutorialNextButton.isHidden = true
        tutorialBackButton.isHidden = true
        topStripe.isHidden = false
        statusBarShouldBeHidden = false
        enableAll()
        update()
    }

    func enableAll() {
        fsCalendarButton.isEnabled = true
        addButton.isHidden = false
    }

    func disableAll() {
        fsCalendarButton.isEnabled = false
        addButton.isHidden = true
    }

    func stepDragComplete() {
        if tutorialStep == .drag {
            tutorialNextButton.layer.borderColor = UIColor.blue.cgColor
            tutorialNextButton.isEnabled = true

        }
    }
    func stepLockedComplete() {
        /*
        if tutorialStep == .lock || tutorialStep == 6 {
            tutorialNextButton.layer.borderColor = UIColor.blue.cgColor
            tutorialNextButton.isEnabled = true
        } */
    }
    func stepDeleteComplete() {
        if tutorialStep == .delete {
            tutorialNextButton.layer.borderColor = UIColor.blue.cgColor
            tutorialNextButton.isEnabled = true
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
            tableViewController.dateInt = currDateInt

            /*
             if let sDate = selectedDate {
             selectedDateInt = dateToHashableInt(date: sDate)
             }
             else {
             selectedDateInt = nil
             }
             */

        }
        /*
         else if(segue.identifier == "toSettings") {
         let settingsViewController = segue.destination as! SettingsViewController
         settingsViewController.svc = self
         } */

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
        calendar.isHidden = false

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
    //MARK: AccessoryTextFieldDelegate functions

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

    func setNextButton(_ tutStep: Tut) {
        let button = tutorialNextButton!
        let nextTutStep = Tut(tutStep.rawValue + 1)
        button.isHidden = false
        if tutStep == .welcome {
            button.setTitle("Yes", for: .normal)
            return
        }
        switch nextTutStep {
        case .drag:
            button.setTitle("Next!", for: .normal)
        case .delete:
            button.setTitle("Next!", for: .normal)
        case .done:
            button.setTitle("Done!", for: .normal)
        default:
            button.setTitle("Next!", for: .normal)
        }
        //to avoid animation when called in non-animation block
        button.layoutIfNeeded()
    }
    func setBackButton(_ tutStep: Tut) {
        let button = tutorialBackButton!
        if tutorialStep == .done {
            button.isHidden = true
        } else if tutorialStep == .welcome {
            button.isHidden = false
            button.setTitle("Skip", for: .normal)
            button.setTitleColor(.red, for: .normal)
        } else {
            button.isHidden = false
            button.setTitle("Back", for: .normal)
            button.setTitleColor(nil, for: .normal)
        }

        //to avoid animation when called in non-animation block
        button.layoutIfNeeded()
    }
    func setTutorial(step tutorialStep: Tut) {
        disableAll()
        if tutorialStep == .done {
            removeTutorial()
            return
        }
        switch tutorialStep {
        case .welcome:
            tutInstructions.text = "Welcome to Flux Schedule!\nReady to start the tutorial?"
            tableViewController.scheduleItems = tutItemsWelcome.map{$0.copy()} as! [ScheduleItem]
        case .lock:
            tutInstructions.text = "Tap the blue swirly button in order to lock a task."
            tableViewController.scheduleItems = tutItemsLock.map{$0.copy()} as! [ScheduleItem]
        case .drag:
            tutInstructions.text = "Now try holding and dragging the blue swirly button to reorder the two items."
            tableViewController.scheduleItems = tutItemsDrag.map{$0.copy()} as! [ScheduleItem]
        case .delete:
            tutInstructions.text = "Swipe left in order to delete an item."
            tableViewController.scheduleItems = tutItemsDelete.map{$0.copy()} as! [ScheduleItem]
        /*
        case .double:
            tutInstructions.text = "Double tap the blue swirly button to split an item."
            tableViewController.scheduleItems = tutItemsDouble.map{$0.copy()} as! [ScheduleItem] */
        
        default:
            break
        }
        tableViewController.updateFromSVC()
        tableViewController.tableView.reloadData()

        UIView.performWithoutAnimation {
            setBackButton(tutorialStep)
            setNextButton(tutorialStep)
        }
        adjustContainerView()
    }
    @IBAction func tutorialNextButtonPressed(_ sender: UIButton) {

        tutorialStep = Tut(tutorialStep.rawValue + 1)
        saveTutorialStep()
        print(tutorialStep)
        setTutorial(step: tutorialStep)
        if tutorialStep == .done {
            hasFinishedTutorial = true
            saveBasic(data: hasFinishedTutorial, key: Paths.hasFinishedTutorial)
        }
        /*
        if tutorialStep == 1 {
            tutorialStep += 1
            tableViewController.scheduleItems = tutorialStepTap
            tableViewController.updateFromSVC()
            sender.setTitle("Next", for: .normal)
            saveTutorialStep()
        }
        else if tutorialStep == 2 {
            tutorialStep = 7
            tableViewController.scheduleItems = tutorialStepSwipe
            tableViewController.updateFromSVC()
            sender.setTitle("Done!", for: .normal)
            saveTutorialStep()
            tutorialNextButton.layer.borderColor = UIColor.blue.withAlphaComponent(0.1).cgColor
            sender.isEnabled = false
        }
        else if tutorialStep == 7 {
            tutorialStep = 3
            tableViewController.scheduleItems = tutorialStepLock
            if !userSettings.fluxPlus {
                tutorialStep = 4
                tableViewController.scheduleItems = tutorialStepDrag
            }
            tableViewController.updateFromSVC()
            sender.setTitle("Done!", for: .normal)

            saveTutorialStep()
            tutorialNextButton.layer.borderColor = UIColor.blue.withAlphaComponent(0.1).cgColor
            sender.isEnabled = false
        }
        else if tutorialStep == 3 {

            tutorialStep += 1
            tableViewController.scheduleItems = tutorialStepDrag
            tableViewController.updateFromSVC()
            sender.setTitle("Done! Now give me an example.", for: .normal)
            sender.layer.borderColor = UIColor.blue.withAlphaComponent(0.1).cgColor
            sender.isEnabled = false
            saveTutorialStep()
        }
        else if tutorialStep == Tut(4) {
            tutorialStep +=
            tableViewController.scheduleItems = tutorialStepExample
            tableViewController.updateFromSVC()
            sender.setTitle("Done. Let me make my own!", for: .normal)
            saveTutorialStep()
        }
        else if tutorialStep == Tut(5) || tutorialStep == Tut(6) {
            tutorialStep = Tut(0)
            update()
            saveTutorialStep()
            tutorialNextButton.isHidden = true
        } */
    }
    @IBAction func tutorialBackButtonPressed(_ sender: UIButton) {
        if tutorialStep == .welcome {
            let okAction = UIAlertAction(title: "Skip", style: .destructive, handler: {(alert: UIAlertAction!) in self.tutorialStep = .done
                self.saveTutorialStep()
                self.removeTutorial()
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil
            )
            presentAlert(title: "Are you sure?", message: "Skip the tutorial? It will always be available in Settings later." , actions: cancelAction, okAction)
            return
        }
        tutorialStep = Tut(tutorialStep.rawValue - 1)
        saveTutorialStep()
        setTutorial(step: tutorialStep)
        /*
         if tutorialStep == 1 {
         tutorialStep += 1
         tableViewController.scheduleItems = tutorialStepTap
         tableViewController.updateFromSVC()
         sender.setTitle("Next", for: .normal)
         saveTutorialStep()
         }
         else if tutorialStep == 2 {
         tutorialStep = 7
         tableViewController.scheduleItems = tutorialStepSwipe
         tableViewController.updateFromSVC()
         sender.setTitle("Done!", for: .normal)
         saveTutorialStep()
         tutorialNextButton.layer.borderColor = UIColor.blue.withAlphaComponent(0.1).cgColor
         sender.isEnabled = false
         }
         else if tutorialStep == 7 {
         tutorialStep = 3
         tableViewController.scheduleItems = tutorialStepLock
         if !userSettings.fluxPlus {
         tutorialStep = 4
         tableViewController.scheduleItems = tutorialStepDrag
         }
         tableViewController.updateFromSVC()
         sender.setTitle("Done!", for: .normal)

         saveTutorialStep()
         tutorialNextButton.layer.borderColor = UIColor.blue.withAlphaComponent(0.1).cgColor
         sender.isEnabled = false
         }
         else if tutorialStep == 3 {

         tutorialStep += 1
         tableViewController.scheduleItems = tutorialStepDrag
         tableViewController.updateFromSVC()
         sender.setTitle("Done! Now give me an example.", for: .normal)
         sender.layer.borderColor = UIColor.blue.withAlphaComponent(0.1).cgColor
         sender.isEnabled = false
         saveTutorialStep()
         }
         else if tutorialStep == Tut(4) {
         tutorialStep +=
         tableViewController.scheduleItems = tutorialStepExample
         tableViewController.updateFromSVC()
         sender.setTitle("Done. Let me make my own!", for: .normal)
         saveTutorialStep()
         }
         else if tutorialStep == Tut(5) || tutorialStep == Tut(6) {
         tutorialStep = Tut(0)
         update()
         saveTutorialStep()
         tutorialNextButton.isHidden = true
         } */
    }
    //MARK: Helper functions

    //adds recurring tasks to new schedules
    //updates tableViewController
    //updates self
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
            schedules[selectedDateInt ?? currDateInt] = [ScheduleItem(name: "Plan out day", duration: 60 * 10, startTime: userSettings.defaultStartTime)]
        }
        else if !schedulesEdited.contains(selectedDateInt ?? currDateInt) || schedules[selectedDateInt ?? currDateInt] == nil{
            if selectedDateInt ?? currDateInt == currDateInt {
                schedules[selectedDateInt ?? currDateInt] = [ScheduleItem(name: "Plan out day", duration: 60 * 10, startTime: tableViewController.getCurrentDurationFromMidnight())]
            }
            else {
                schedules[selectedDateInt ?? currDateInt] = [ScheduleItem(name: userSettings.defaultName, duration: userSettings.defaultDuration, startTime: userSettings.defaultStartTime)]
            }

        }

        if tutorialStep != Tut(0) {
            /*
            if tutorialStep == Tut(999) {
                tableViewController.scheduleItems = tutorialStepWelcome
            }
            else if tutorialStep == Tut(2) {
                tableViewController.scheduleItems = tutorialStepTap
            }
            else if tutorialStep == Tut(3) {
                tableViewController.scheduleItems = tutorialStepLock
            }
            else if tutorialStep == Tut(4) || tutorialStep == Tut(6) {
                tableViewController.scheduleItems = tutorialStepDrag
            } else if tutorialStep == Tut(5) {
                tableViewController.scheduleItems = tutorialStepExample
            }
            else if tutorialStep == Tut(7) {
                tableViewController.scheduleItems = tutorialStepDelete
            } */
            if tutorialStep != .done {
                if tutorialStep == .welcome {
                    tableViewController.scheduleItems = tutItemsWelcome
                }
                else if tutorialStep == .lock {
                    tableViewController.scheduleItems = tutItemsLock
                }
                else if tutorialStep == .drag {
                    tableViewController.scheduleItems = tutItemsDrag
                }
                else if tutorialStep == .delete {
                    tableViewController.scheduleItems = tutItemsDelete
                } /*
                else if tutorialStep == .double {
                    tableViewController.scheduleItems = tutItemsDouble
                } */
            }
            else {
                tableViewController.scheduleItems = schedules[selectedDateInt ?? currDateInt]!
            }
        }
        else {
            tableViewController.scheduleItems = schedules[selectedDateInt ?? currDateInt]!
        }
        //tableViewController.scheduleItems = [ScheduleItem(name: "Morning routine", duration: 45 * 60, startTime: 7 * 3600), ScheduleItem(name: "Inspect Instagram", duration: 15 * 60), ScheduleItem(name: "Museum", duration: 90 * 60, locked: userSettings.fluxPlus), ScheduleItem(name: "Tour the market", duration: 40 * 60, locked: userSettings.fluxPlus), ScheduleItem(name: "Space needle", duration: 40 * 60), ScheduleItem(name: "Brunch at buffet", duration: 80 * 60), ScheduleItem(name: "Meet up with family", duration: userSettings.defaultDuration), ScheduleItem(name: "Ride the ferr", duration: userSettings.defaultDuration)]
        
        //tableViewController.scheduleItems = [ScheduleItem(name: "Morning routine", duration: 45 * 60, startTime: 7 * 3600), ScheduleItem(name: "Check Facebook", duration: 15 * 60), ScheduleItem(name: "Go work", duration: 8 * 3600, locked: true), ScheduleItem(name: "Donuts with co-workers", duration: 30 * 60, locked: true), ScheduleItem(name: "Respond to emails", duration: 20 * 60), ScheduleItem(name: "Work on side-project", duration: 45 * 60), ScheduleItem(name: "Pick up Benjamin", duration: userSettings.defaultDuration)]
        //tableViewController.scheduleItems = [ScheduleItem(name: "Westworld season 2", duration: 45 * 60, startTime: 7 * 3600), ScheduleItem(name: "Finish essay", duration: 15 * 60), ScheduleItem(name: "10 min abs", duration: 8 * 3600)]
        //tableViewController.scheduleItems = [ScheduleItem(name: "Dinner", duration: 40 * 60, startTime: 18 * 3600)]
        tableViewController.dateInt = selectedDateInt ?? currDateInt
        tableViewController.updateFromSVC()


        let date = intToDate(int: selectedDateInt ?? currDateInt)

        dateTextField.text = dateDescription(date: intToDate(int: selectedDateInt ?? currDateInt))
        weekdayLabel.text = "\(date.format(format: "EEEE")), \(date.format(format: "MMM")) \(date.format(format: "d"))"
        //dateTextField.text = intDateDescription(int: selectedDateInt ?? currDateInt)
        //saveScheduleDates()
        saveSchedules()
        //saveSchedulesData()
        updateStreakButton()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1)) {
            self.calendar.updateBoundingRect()
        }
    }

    func tvcUpdated() {
        updateStreakButton()

    }
    func updateStreakButton() {
        streakLabel.text = String(calculateDailyStreak(tableViewController.streakStats))
        print(String(calculateDailyStreak(tableViewController.streakStats)))
    }

    func saveTutorialStep() {
        if sharedDefaults != nil {
            sharedDefaults.set(tutorialStep.rawValue + 1, forKey: Paths.tutorialStep)
        }
    }

    func loadTutorialStep() -> Tut? {

        if sharedDefaults != nil {
            if let step = sharedDefaults.value(forKey: Paths.tutorialStep) as? Int
            {
                if step == 1 {
                    return Tut(0)
                }
                else if step == 7 {
                    return Tut(6)
                }
                else {
                    return Tut(1)
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
            return
        }

        if sharedDefaults != nil {
            NSKeyedArchiver.setClassName("ScheduleItem", for: ScheduleItem.self)
            sharedDefaults.set(NSKeyedArchiver.archivedData(withRootObject: schedules), forKey: Paths.schedules)
            sharedDefaults.set(NSKeyedArchiver.archivedData(withRootObject: schedulesEdited), forKey: Paths.schedulesEdited)
            print("schedules saved")
        }
    }

    func loadSchedules() -> [Int:[ScheduleItem]]? {


        if sharedDefaults != nil {
            if let data = sharedDefaults.object(forKey: Paths.schedules) as? Data {
                NSKeyedUnarchiver.setClass(ScheduleItem.self, forClassName: "ScheduleItem")
                let unarcher = NSKeyedUnarchiver(forReadingWith: data)
                return unarcher.decodeObject(forKey: "root") as? [Int:[ScheduleItem]]
            }
        }
        else {
            print("tried to access default EARLY")
        }
        loadedSchedules = true
        return nil
    }
    func loadSchedulesEdited() -> Set<Int>? {
        if let data = sharedDefaults.object(forKey: Paths.schedulesEdited) as? Data {
            let unarcher = NSKeyedUnarchiver(forReadingWith: data)
            return unarcher.decodeObject(forKey: "root") as? Set<Int>
        }
        return nil
    }

    @IBAction func calendarTodayButtonPressed(_ sender: UIButton) {
        changeDate(intDate: currDateInt)
    }

    @IBAction func addButtonPressed(_ sender: UIButton) {
        if calendar.isHidden || true {
            tableViewController!.addButtonPressed()
        } else {
            changeDate(intDate: currDateInt)
            hideCalendar()
        }
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
        let delay5 = UNNotificationAction(identifier: "delay5",
                                          title: "Delay by 5 minutes",
                                          options: UNNotificationActionOptions(rawValue: 0))

        let taskNoAction = UNNotificationCategory(identifier: "taskNoAction",
                                                  actions: [],
                                                  intentIdentifiers: [],
                                                  options: UNNotificationCategoryOptions(rawValue: 0))
        let taskWithAction = UNNotificationCategory(identifier: "taskWithAction",
                                                    actions: [delay5, delay],
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
                    if let startDate = i.startTime, i.taskName != userSettings.defaultName {
                        if startDate > tableViewController.getCurrentDurationFromMidnight() {
                            let content = UNMutableNotificationContent()
                            content.title = "\(i.taskName)"
                            content.body = "\(timeDescription(durationSinceMidnight: i.startTime!))"
                            content.categoryIdentifier = withAction ? "taskWithAction": "taskNoAction"
                            content.userInfo = ["notifDate": startDate]
                            content.sound = UNNotificationSound.default()

                            var dateComponents = DateComponents()
                            dateComponents.hour = startDate / 3600
                            dateComponents.minute = (startDate % 3600) / 60
                            var trigger: UNNotificationTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                            //trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                            center.add(request)
                        }
                    }
                }
            }
        }

    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
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

            var delay = appDelegate.userSettings.notifDelayTime
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                print("default action notification")
            case "delay5":
                delay = 5
                fallthrough
            case "delay":
                // the user tapped our "show more info…" button
                print("delay task")


                for i in 0..<(schedules[currDateInt] ?? []).count {

                    if schedules[currDateInt]![i].startTime != nil && schedules[currDateInt]![i].startTime! == notifDate {

                        if(i > 0) {
                            schedules[currDateInt]![i - 1].duration += delay * 60

                            if(selectedDateInt ?? currDateInt == currDateInt) {
                                update()

                            }
                            break
                        }
                        if(i == 0) {
                            schedules[currDateInt]![0].startTime! += delay * 60
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
        scheduleTaskNotifs(withAction: true)
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
        changeDate(intDate: (selectedDateInt ?? currDateInt) + change)
    }
    func changeDate(intDate: Int) {
        selectedDateInt = intDate
        calendar.select(intToDate(int: selectedDateInt ?? currDateInt))
        update()
    }

    @IBAction func testingModeButtonPressed(_ sender: UIButton) {
        testingMode = !testingMode
        tableViewController.testingMode = testingMode
        if testingMode {
            sender.backgroundColor = .red
            tutorialStep = Tut(1)
            addTutorial()
            update()
        }
        else {
            sender.backgroundColor = .blue
        }

    }
    @IBAction func fsCalendarButtonPressed(_ sender: UIButton) {

        if calendar.isHidden {
            showCalendar()
        } else {
            hideCalendar()
        }

    }
    func styleAddButtonPlus() {
        addButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)
        addButton.layer.cornerRadius = 0.5 * addButton.bounds.size.width
        addButton.titleLabel?.baselineAdjustment = .alignBaselines
        let separatorColor = tableViewController.tableView.separatorColor
        addButton.layer.borderColor = separatorColor?.cgColor
        addButton.layer.borderWidth = 0.5
        addButton.backgroundColor = .white

    }
    func styleTutButton(button: UIButton) {
        button.layer.cornerRadius = 2
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.blue.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    func showCalendar() {
        calendar.updateBoundingRect()

        calendar.select(intToDate(int: selectedDateInt ?? currDateInt))
        calendar.isHidden = false

        let moveDist = ((calendarHeightConstraint.secondItem as! UIView).frame.height) * calendarHeightConstraint.multiplier
        calendarBottomSpaceConstraint.constant = moveDist



        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            self.view.layoutIfNeeded()

        }, completion: { (finished) -> Void in

        })
        calendar.updateBoundingRect()
    }
    func hideCalendar() {
        calendarBottomSpaceConstraint.constant = 0
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseIn, animations: { () -> Void in
            self.view.layoutIfNeeded()

        }, completion: { (finished) -> Void in
            self.calendar.isHidden = true
        })
    }
    /*
     func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
     let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position)
     return cell
     }

     func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {

     } */

    func calendar(_ calendar: FSCalendar, titleFor date: Date) -> String? {
        if self.gregorian.isDateInToday(date) {
            return "T"
        }
        return nil
    }

    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return 0
    }

    // MARK:- FSCalendarDelegate

    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendar.frame.size.height = bounds.height
        //self.eventLabel.frame.origin.y = calendar.frame.maxY + 10
    }
    /*
     func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition)   -> Bool {
     return monthPosition == .current
     }

     func calendar(_ calendar: FSCalendar, shouldDeselect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
     print(FSCalendarMonthPosition.current.rawValue)
     print("hey")
     return monthPosition == .current
     }
     */
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {


        hideCalendar()
        selectedDateInt = dateToHashableInt(date: date)
        update()
    }


    func calendar(_ calendar: FSCalendar, didDeselect date: Date) {
    }



    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        if self.gregorian.isDateInToday(date) {
            return [UIColor.orange]
        }
        return [appearance.eventDefaultColor]
    }
    /*
     func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {

     for i in tableViewController.streakStats.markedDays {
     if self.gregorian.isDate(intToDate(int: i), inSameDayAs: date) {
     return UIColor.purple
     }
     }
     return appearance.titleDefaultColor
     } */
    /*
     func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
     print(date.month)
     print("j")
     if self.gregorian.isDateInToday(date) {
     return UIColor(displayP3Red: 198/255, green: 51/255, blue: 42/255, alpha: 1)
     }
     return FSColorRGBA(31,119,219,1.0)
     } */

}
