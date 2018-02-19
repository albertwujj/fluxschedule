//
//  ScheduleTableViewController.swift
//  Schedule Maker Prototype
//
//  Created by Albert Wu on 11/7/17.
//  Copyright © 2017 Old Friend. All rights reserved.
//

import os.log
import UIKit
import UserNotifications

class ScheduleTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userSettings: Settings!
    var sharedDefaults: UserDefaults!
    var cellSnapshot: UIView?
    var initialIndexPath: IndexPath? = nil
    var veryInitialIndexPath : IndexPath? = nil
    var firstTouch: IndexPath?
    var isAnyLockedItems: Bool = false
    var didDragLockedItem = false
    var darkPurple = UIColor.blue
    var testingMode = false
    var rowHeight = 0
    var itemsToGreen: [ScheduleItem] = []
    var itemsToFullGreen: [ScheduleItem] = []
    var itemsToRed: [ScheduleItem] = []
    var shouldSelectLast = false
    var prevScrollPos: IndexPath?
    var duringKeyboardScroll = false

    @IBOutlet weak var header: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    
    
    
    var scheduleViewController: ScheduleViewController!
    
    var scheduleItems: [ScheduleItem] = [ScheduleItem(name: "BUG! IF YOU SEE THIS", duration: 30 * 60)]
    var origLockedItems: [ScheduleItem] = []
    var currDateInt = 0
    
    @IBOutlet var tableView: UITableView!
    //MARK: Initialization
    override func viewDidLoad() {
        if let loadedDefaults = UserDefaults(suiteName: "group.9P3FVEPY7V.group.AlbertWu.ScheduleMakerPrototype") {
            sharedDefaults = loadedDefaults
        } else {
            print("UserDefaults BUG")
        }
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 240, right: 0)
        self.tableView.contentInset = insets
        darkPurple = UIColor(displayP3Red: 52/255, green: 8/255, blue: 107/255, alpha: 0.35)
        //tableView.separatorColor = darkPurple
        
        userSettings = appDelegate.userSettings
        super.viewDidLoad()
        
        //update()
        //Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(highlightCurrCell), userInfo: nil, repeats: true)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        addLongPressGesture()
        
        /*
        for cell in tableView.subviews where cell is ScheduleTableViewCell {
            for textField in cell.subviews[0].subviews where textField is UITextField {
                for gestureRecognizer in (textField as! UITextField).gestureRecognizers ?? [] {
                    if gestureRecognizer is UILongPressGestureRecognizer {
                        gestureRecognizer.isEnabled = false
                    }
                    print("FUUUUCK")
                }
            }
        }
 */
        
        
        changeRowHeight()
        tableView.delegate = self
        tableView.dataSource = self
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(rowHeight)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        update()
        if currDateInt == scheduleViewController.dateToHashableInt(date: Date()), let scrollPosition = loadScrollPosition() {
            scrollToTop(indexPath: scrollPosition)
        }
    }
   
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        changeRowHeight()
    }
    func changeRowHeight() {
        DispatchQueue.main.async {
            
        
            if UIDevice.current.orientation.isLandscape {
    
                if (UIScreen.main.bounds.height < 600) {
                    self.rowHeight = 43
                } else {
                    self.rowHeight = 45
                }
            } else {
 
                if (UIScreen.main.bounds.height < 600) {
                    self.rowHeight = 45
                } else {
                    self.rowHeight = 60
                }
            }
            self.tableView.reloadData()
        }
    }
    func flashItems(itemsToFlash: [ScheduleItem], for tfID: Int, color: UIColor) {
        for i in 0..<self.scheduleItems.count {
            for j in itemsToFlash {
                if j === scheduleItems[i] {
                    if let cell = self.tableView.cellForRow(at: IndexPath(i)) as? ScheduleTableViewCell {
                        var tf: UIView!
                        if tfID == 0 {
                            tf = cell.startTimeTF
                        } else if tfID == 1 {
                            tf = cell.durationTF
                        } else if tfID == 2{
                            tf = cell.subviews[0]
                        }
                        
                        
                        UIView.animate(
                                withDuration: 0.7,
                                delay: 0,
                                options: [UIViewAnimationOptions.beginFromCurrentState],
                                animations: { () -> Void in
                            tf.backgroundColor = color.withAlphaComponent(0.3)
                        }, completion: { (finished) -> Void in
                            DispatchQueue.main.async {
                                UIView.animate(withDuration: 1.5, animations: { () -> Void in
                                    tf.backgroundColor = color.withAlphaComponent(0.3)
                                    
                                }, completion: { (finished) -> Void in
                                    DispatchQueue.main.async {
                                        UIView.animate(withDuration: 0.9, animations: { () -> Void in
                                            tf.backgroundColor = .white
                                            
                                        }, completion: { (finished) -> Void in
                                            
                                        })
                                    }
                                })
                            }
                        })
                    }
                    break
                }
            }
        }
        highlightCurrCell()
    }
    func flashOnItems(itemsToFlash: [ScheduleItem], for tfID: Int, color: UIColor, timeToFullColor: TimeInterval = 0.7) {
        for i in 0..<self.scheduleItems.count {
            for j in itemsToFlash {
                if j === scheduleItems[i] {
                    if let cell = self.tableView.cellForRow(at: IndexPath(i)) as? ScheduleTableViewCell {
                        var tf: UIView!
                        if tfID == 0 {
                            tf = cell.startTimeTF
                        } else if tfID == 1 {
                            tf = cell.durationTF
                        } else if tfID == 2{
                            tf = cell.subviews[0]
                    
                        }
                        
                        
                        
                       
                            
                        
                        UIView.animate(withDuration: timeToFullColor, animations: { () -> Void in
                            tf.backgroundColor = color.withAlphaComponent(0.3)
                            
                        }, completion: { (finished) -> Void in
                            
                        })
                        
                        
                    }
                    break
                }
            }
        }
        highlightCurrCell()
    }
    func deFlashItems(itemsToFlash: [ScheduleItem], for tfID: Int, timeToFullColor: TimeInterval = 0.7) {
        for i in 0..<self.scheduleItems.count {
            for j in itemsToFlash {
                if j === scheduleItems[i] {
                    if let cell = self.tableView.cellForRow(at: IndexPath(i)) as? ScheduleTableViewCell {
                        var tf: UIView!
                        if tfID == 0 {
                            tf = cell.startTimeTF
                        } else if tfID == 1 {
                            tf = cell.durationTF
                        } else if tfID == 2{
                            tf = cell.subviews[0]
                    
                        }
                        
                        
                      
                        DispatchQueue.main.async {
                            UIView.animate(withDuration: 0.9, animations: { () -> Void in
                                tf.backgroundColor = .white
                                
                            }, completion: { (finished) -> Void in
                                
                            })
                        }
                               
                    }
                    break
                }
            }
        }
        highlightCurrCell()
    }
    
    func flashScheduleItem(_ time: Int, for tfID: Int, color: UIColor) {
        /*
        var j = 99
        for i in 0..<scheduleItems.count {
            if tableView.indexPathsForVisibleRows != nil && tableView.indexPathsForVisibleRows!.contains(IndexPath(i)) {
                if scheduleItems[i] === scheduleItem {
                    let cell = tableView.cellForRow(at: IndexPath(i)) as! ScheduleTableViewCell
                    let greenColorView = UIView()
                    let green = UIColor.green
                    greenColorView.backgroundColor = green.withAlphaComponent(0.3)
                    greenColorView.layer.masksToBounds = true
                    
                 
                    let whiteColorView = UIView()
                    let white = UIColor.white
                    whiteColorView.backgroundColor = white
                    whiteColorView.layer.masksToBounds = true
                    UIView.animate(withDuration: 1, animations: { () -> Void in
                        cell.backgroundView = greenColorView
                        
                        
                    }, completion: { (finished) -> Void in
                        UIView.animate(withDuration: 1, animations: { () -> Void in
                            cell.backgroundView = whiteColorView
                            
                        }, completion: { (finished) -> Void in
                            
                        })
                        
                    })
                    
                    j = i
                    break
                }
            }
        }
        
        
        */
       
            
        
            for i in 0..<self.scheduleItems.count {
                if (tfID == 0 ? self.scheduleItems[i].startTime : self.scheduleItems[i].duration) == time {
                    
                    if let cell = self.tableView.cellForRow(at: IndexPath(i)) as? ScheduleTableViewCell {
                        var tf: AccessoryTextField!
                        if tfID == 0 {
                            tf = cell.startTimeTF
                        } else {
                            tf = cell.durationTF
                        }
   
                        
                        
                        UIView.animate(withDuration: 0.7, animations: { () -> Void in
                            tf.backgroundColor = color.withAlphaComponent(0.3)
                            
                        }, completion: { (finished) -> Void in
                            DispatchQueue.main.async {
                                UIView.animate(withDuration: 1.5, animations: { () -> Void in
                                    tf.backgroundColor = color.withAlphaComponent(0.3)
                                    
                                }, completion: { (finished) -> Void in
                                    DispatchQueue.main.async {
                                        UIView.animate(withDuration: 0.9, animations: { () -> Void in
                                            tf.backgroundColor = .white
                                            
                                        }, completion: { (finished) -> Void in
                                            
                                        })
                                    }
                                })
                            }
                        })
                        
                       
                        
                    }
                }
            }
        
    
   
        highlightCurrCell()
    
    }
 
    /*
    @objc func dehighlightCell(timer: Timer) {
        let scheduleItem = timer.userInfo as! ScheduleItem
        for i in 0..<scheduleItems.count {
            if tableView.indexPathsForVisibleRows != nil && tableView.indexPathsForVisibleRows!.contains(IndexPath(i)) {
                if scheduleItems[i] === scheduleItem {
                    let cell = tableView.cellForRow(at: IndexPath(i)) as! ScheduleTableViewCell
                    let whiteColorView = UIView()
                    let orig = UIColor.white
                    whiteColorView.layer.masksToBounds = true
                    UIView.animate(withDuration: 0.25, dealyanimations: { () -> Void in
                        cell.backgroundView = whiteColorView
                        
                    }, completion: { (finished) -> Void in
                        
                    })
                    
                    
                }
                
            }
        }
    }
    */
    //MARK: Drag and Drop Table View Cell Functions
    func addLongPressGesture() {
        
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressGesture(sender:)))
       
        tableView.addGestureRecognizer(longpress)
        
    }
    func quickReloadCellTimes(index: Int) {
        for path in tableView.indexPathsForVisibleRows! where path.row < scheduleItems.count {
            let row = path.row
            let scheduleItem = scheduleItems[row]
            if let cell = tableView.cellForRow(at: path) as? ScheduleTableViewCell {
                if scheduleItem.locked {
                    cell.startTimeTF.text = ScheduleTableViewCell.timeDescription(durationSinceMidnight: scheduleItem.initialStartTime!)
                } else {
                    cell.startTimeTF.text = ScheduleTableViewCell.timeDescription(durationSinceMidnight: scheduleItem.startTime!)
                    if scheduleItem.startTime != scheduleItem.initialStartTime {
        
                        cell.startTimeTF.backgroundColor = UIColor.purple.withAlphaComponent(0.3)
                     }
                    else {
                        cell.startTimeTF.backgroundColor = UIColor.white
                    }
                    scheduleItem.previousStartTime = scheduleItem.startTime
                }

                cell.durationTF.text = ScheduleTableViewCell.durationDescription(duration: scheduleItem.duration)
                cell.row = row
            }
        }
        highlightCurrCell()
    }
    func quickReloadCells() {
            for path in tableView.indexPathsForVisibleRows! {
                let row = path.row
                if row < scheduleItems.count{
                    let scheduleItem = scheduleItems[row]
                    if let cell = tableView.cellForRow(at: path) as? ScheduleTableViewCell {
                        cell.startTimeTF.text = ScheduleTableViewCell.timeDescription(durationSinceMidnight: scheduleItem.startTime!)
                        cell.durationTF.text = ScheduleTableViewCell.durationDescription(duration: scheduleItem.duration)
                        cell.lockButton.setTitle(scheduleItem.locked ? "🔒" : "🌀",for: .normal)
                        cell.taskNameTF.text = scheduleItem.taskName
                        cell.row = row
                        if(!duringKeyboardScroll){
                            cell.origRow = row
                            cell.origScheduleItem = scheduleItem
                        }
                    }
                }
            }
            highlightCurrCell()
    }

    @objc func onLongPressGesture(sender: UILongPressGestureRecognizer) {
     
        duringKeyboardScroll = false
        let locationInView = sender.location(in: tableView)
        var indexPath = tableView.indexPathForRow(at: locationInView)
        
        if sender.state == .began && indexPath != nil {
            if indexPath!.row >= scheduleItems.count {
                return
            }
            captureInitial()
            didDragLockedItem = false
            if let path = indexPath  {
                let cell = scheduleItems[path.row]
                if cell.locked {
                    didDragLockedItem = true
                }
            }
            
            origLockedItems = []
            for scheduleItem in scheduleItems {
                if scheduleItem.locked {
                    
                    isAnyLockedItems = true
                    origLockedItems.append(scheduleItem.deepCopy())
                }
            }
            if !didDragLockedItem {
                veryInitialIndexPath = indexPath!
                initialIndexPath = indexPath!
                let cell = tableView.cellForRow(at: indexPath!) as? ScheduleTableViewCell
                UIView.animate(withDuration: 0.7, animations: { () -> Void in
                    //cell?.startTimeTF.backgroundColor = UIColor.purple.withAlphaComponent(0.3)
                    
                }, completion: { (finished) -> Void in
                    
                })
                self.cellSnapshot = snapshotOfCell(inputView: cell!)
                var center = cell?.center
                cellSnapshot?.center = center!
                cellSnapshot?.alpha = 0.0
                tableView.addSubview(cellSnapshot!)
                
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    center?.y = locationInView.y
                    self.cellSnapshot?.center = center!
                    self.cellSnapshot?.transform = (self.cellSnapshot?.transform.scaledBy(x: 1.05, y: 1.05))!
                    self.cellSnapshot?.alpha = 0.99
                    cell?.alpha = 0.0
                }, completion: { (finished) -> Void in
                    if finished {
                        cell?.isHidden = true
                    }
                })
            }
        } else if initialIndexPath != nil && !didDragLockedItem && sender.state == .changed {
            var center = cellSnapshot!.center
            center.y = locationInView.y
            cellSnapshot?.center = center
            

            if indexPath != nil && indexPath!.row < scheduleItems.count && indexPath != initialIndexPath && !scheduleItems[indexPath!.row].locked {

                adjustScheduleItems(index: indexPath!.row)

                recalculateTimesBasic()
                quickReloadCellTimes(index: indexPath!.row)

                if let cell = tableView.cellForRow(at: indexPath!) as? ScheduleTableViewCell {
                    //cell.startTimeTF.backgroundColor = UIColor.purple.withAlphaComponent(0.3)
                    cell.isHidden = false
                    cell.alpha = 1
                    self.cellSnapshot?.removeFromSuperview()
                    self.cellSnapshot = snapshotOfCell(inputView: cell)
                    cell.alpha = 0
                    cell.isHidden = true
                    self.cellSnapshot!.center = center
                    self.cellSnapshot?.transform = (self.cellSnapshot?.transform.scaledBy(x: 1.05, y: 1.05))!
                    self.cellSnapshot?.alpha = 0.99
                    tableView.addSubview(cellSnapshot!)
                    initialIndexPath = indexPath
                }
            }
        } else if initialIndexPath != nil && !didDragLockedItem && sender.state == .ended {
            var currPath: IndexPath?
            var item: ScheduleItem?
            let cell = tableView.cellForRow(at: initialIndexPath!) as? ScheduleTableViewCell
            cell?.isHidden = false
            cell?.alpha = 0.0
            if cell != nil {
                currPath = initialIndexPath
                item = scheduleItems[currPath!.row]
                if(veryInitialIndexPath!.row != initialIndexPath!.row) {
                    scheduleViewController.step3Complete()
                }
            }
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.cellSnapshot?.center = (cell?.center)!
                self.cellSnapshot?.transform = CGAffineTransform.identity
                self.cellSnapshot?.alpha = 0.0
                cell?.alpha = 1.0
            }, completion: { (finished) -> Void in
                if finished {
                    self.initialIndexPath = nil
                    self.cellSnapshot?.removeFromSuperview()
                    self.cellSnapshot = nil
                }
            })
            
            
            isAnyLockedItems = false
            didDragLockedItem = false
            veryInitialIndexPath = nil
            
            recalculateTimes(with: origLockedItems)
            updateNoRecalculate()
            scheduleViewController.schedulesEdited.insert(currDateInt)
            self.cellSnapshot?.removeFromSuperview()
            /*
            if currPath != nil && item != nil && item!.inColor {
                flashItems(itemsToFlash: [item!], for: 0, color: .purple)
                item!.inColor = false
            } */
            deFlashItems(itemsToFlash: scheduleItems, for: 0)
            currPath = nil
            item = nil
           
        }
        
    }
    func adjustScheduleItems(index: Int) {
        
        
        var initialIndex = initialIndexPath!.row
        var index = index
        
        let movingDown = initialIndex < index
        let movingUp = !movingDown
        
        var previousFirstStartTime = scheduleItems[0].startTime!
        var initialDuration = scheduleItems[initialIndex].duration
        
        if movingUp {
            scheduleItems.reverse()
            initialIndex = scheduleItems.count - 1 - initialIndex
            index = scheduleItems.count - 1 - index
        }
        
        var hasLockedTaskTop = false
        
        for element in scheduleItems[0 ..< initialIndex] {
            if element.locked {
                hasLockedTaskTop = true
            }
        }
        
        var hasLockedTaskMiddle = false
        
        for element in scheduleItems[initialIndex + 1 ..< index] {
            if element.locked {
                hasLockedTaskMiddle = true
            }
        }
        
        var hasLockedTaskBottom = false
        
        for element in scheduleItems[(index + 1)...] {
            if element.locked {
                hasLockedTaskBottom = true
            }
        }
        
        var firstStartTimeDelta = !hasLockedTaskTop && hasLockedTaskMiddle && !hasLockedTaskBottom ?
            scheduleItems[initialIndex].duration - scheduleItems[index].duration : 0
        
        var targetIndex = initialIndex
        
        for (i, element) in scheduleItems[0 ..< initialIndex].enumerated() {
            if element.previousStartTime! != element.startTime! &&
                (element.previousStartTime! > element.startTime!) == movingDown {
                targetIndex = i
            }
        }
        
        let beforeTarget = scheduleItems[0 ..< targetIndex]
        let targetToInitial = [scheduleItems[index]] + scheduleItems[targetIndex ..< initialIndex]
        let initialToCurrent = scheduleItems[initialIndex + 1 ..< index] + [scheduleItems[initialIndex]]
        let afterCurrent = scheduleItems[(index + 1)...]
        
        
        scheduleItems = beforeTarget + targetToInitial + initialToCurrent + afterCurrent
        
        if movingUp {
            scheduleItems.reverse()
            targetIndex = scheduleItems.count - 1 - targetIndex
            initialIndex = scheduleItems.count - 1 - initialIndex
            index = scheduleItems.count - 1 - index
            firstStartTimeDelta = -firstStartTimeDelta
        }
        
        tableView.beginUpdates()
        tableView.moveRow(at: IndexPath(initialIndex), to: IndexPath(index))
        tableView.moveRow(at: IndexPath(index), to: IndexPath(targetIndex))
        tableView.endUpdates()
        
        scheduleItems[0].startTime! = previousFirstStartTime
    }
    /*
    func recalculateTimesWith(origLockedItems: [ScheduleItem]) {
        if scheduleItems.count != 0 {
            if var currStartTime = scheduleItems[0].startTime {
                var i = 0
                while(i < scheduleItems.count) {
                    if scheduleItems[i].locked && scheduleItems[i].startTime != nil {
                        scheduleItems.remove(at: i)
                        i -= 1
                    }
                    else {
                        scheduleItems[i].startTime = currStartTime
                        currStartTime += scheduleItems[i].duration
                    }
                    i += 1
                }
                //let sortedOrigLockedItems = origLockedItems.sorted(by: { $0.startTime! < $1.startTime! })
                for j in origLockedItems {
                    insertItem(item: j, newStartTime: j.startTime!)
                    recalculateTimesBasic()
                }
            }
        }
    }
    
    func recalculateTimesAdding(additionalLockedItems: [ScheduleItem]) {
        if scheduleItems.count != 0 {
            if var currStartTime = scheduleItems[0].startTime {
                var origLockedItems: [ScheduleItem] = []
                var i = 0
                while(i < scheduleItems.count){
                    if scheduleItems[i].locked && scheduleItems[i].startTime != nil {
                        scheduleItems[i].oldRow = i
                        
                        origLockedItems.append(scheduleItems.remove(at: i))
                        
                        i -= 1
                    }
                        
                    else {
                        scheduleItems[i].startTime = currStartTime
                        currStartTime += scheduleItems[i].duration
                    }
                    i += 1
                    
                }
                for a in additionalLockedItems {
                    origLockedItems.append(a)
                }
                origLockedItems = origLockedItems.sorted(by: { $0.startTime! < $1.startTime! })
                for j in origLockedItems {
                    insertItem(item: j, newStartTime: j.startTime!)
                    recalculateTimesBasic()
                }
            }
        }
    }
 */
    func deletedLockedItemsAndOrdered() -> [ScheduleItem] {
        var deleted: [ScheduleItem] = []
        var i = 0
        var currStartTime = 0
        if scheduleItems.count > 0 {
            currStartTime = scheduleItems[0].startTime ?? 0
        }
        while i < scheduleItems.count {
            let task = scheduleItems[i]
            if task.locked {
                scheduleItems.remove(at: i)
                
                deleted.append(task)
            }
            else {
                task.startTime = currStartTime
                currStartTime += task.duration
                i += 1
                
            }
        }
        return deleted
    }
    func getLockedItems() -> [ScheduleItem] {
        var lockedItems: [ScheduleItem] = []
        for i in scheduleItems {
            if i.locked {
                lockedItems.append(i.deepCopy())
            }
        }
        return lockedItems
    }
    func recalculateTimes(with lockedTasksP: [ScheduleItem]?) {
        var lockedTasks = lockedTasksP ?? getLockedItems()
        deletedLockedItemsAndOrdered()
        lockedTasks = lockedTasks.sorted(by: { $0.startTime! < $1.startTime! })
        for i in lockedTasks {
            insertItem(item: i, newStartTime: i.startTime!)
            recalculateTimesBasic()
        }
    }
    /*
    //just remove and then put back locked times into array, based on locked start time, in order of said start time
    func recalculateTimes() {
        if scheduleItems.count != 0 {
            if var currStartTime = scheduleItems[0].startTime {
                var origLockedItems: [ScheduleItem] = []
                var i = 0
                while(i < scheduleItems.count){
                    if scheduleItems[i].locked && scheduleItems[i].startTime != nil {
                        scheduleItems[i].oldRow = i
                        
                        origLockedItems.append(scheduleItems.remove(at: i))
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
                    //print("jcount: \(origLockedItems.count)")
                    insertItem(item: j, newStartTime: j.startTime!, sItemsP: nil)
                    
                   
                    
                    //tableView.moveRow(at: IndexPath(row: j.oldRow!, section: 0), to: IndexPath(row: insertItem(item: j, newStartTime: j.startTime!), section: 0))
                    recalculateTimesBasic()
                }
                
            }
            
        }
    }
 */
    func recalculateTimesBasic(with scheduleItemsP: [ScheduleItem]) -> [ScheduleItem] {
        var currStartTime = 0
        if scheduleItemsP.count > 0, let st = scheduleItemsP[0].startTime {
            currStartTime = st
        }
        for i in scheduleItemsP {
            i.startTime = currStartTime
            currStartTime += i.duration
        }
        return scheduleItemsP
    }
    func captureInitial() {
        for i in scheduleItems {
            i.initialStartTime = i.startTime
            i.previousStartTime = i.startTime
            i.initialDuration = i.duration
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
   

    func snapshotOfCell(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let cellSnapshot = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
    
    @objc func saveScrollPosition() {
        
        if let visRows = tableView.indexPathsForVisibleRows{
            if visRows.count > 0 {
                let topPath = visRows[0]
                sharedDefaults.set(NSKeyedArchiver.archivedData(withRootObject: topPath), forKey: Paths.scrollPosition)
            }
        }

    }
    
    func loadScrollPosition() -> IndexPath? {
        if let data = sharedDefaults.object(forKey: Paths.scrollPosition) as? Data {
            let unarcher = NSKeyedUnarchiver(forReadingWith: data)
            if let indexPath = unarcher.decodeObject(forKey: "root") as? IndexPath, indexPath.row < scheduleItems.count {
                return indexPath
            }
            else {
                return nil
            }
        }
        return nil
    }
  
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row < scheduleItems.count) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! ScheduleTableViewCell
            cell.changeFontForScreenSize(tvc: self)
            cell.tableViewController = self
            cell.row = indexPath.row
            cell.scheduleItem = scheduleItems[indexPath.row]
            cell.selectionStyle = .none
            cell.layer.borderColor = appDelegate.userSettings.themeColor.cgColor
            cell.layer.borderWidth = 0.1
            if(!duringKeyboardScroll) {
                cell.origScheduleItem = scheduleItems[indexPath.row]
                cell.origRow = indexPath.row
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
            cell.selectionStyle = .none
            return cell
        }
        
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return scheduleItems.count + 2
    }

   
    /*
     */
    /*
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return header
    }*/
    
    
    
    
    func loadUpdate() {
        
    }
    
    //MARK: Update Data
    func update() {
        //when a ScheduleItem's duration is changed, or when the first ScheduleItem's startTime is changed,
        //recalculate all startTimes based on the first startTime and each scheduleItem's duration
        recalculateTimes(with: nil)
        updateNoRecalculate()
        
       
       
    }
    func updateNoRecalculate() {
        tableView.reloadData()
        mergeSameName()
        tableView.reloadData()
        //tableView.reloadData()
        
        //scheduleViewController.saveSchedule(date: currDateInt, scheduleItems: scheduleItems)
        highlightCurrCell()
        
        normalizeTFLengths()
        if scheduleViewController.tutorialStep == 0 {
            scheduleViewController.schedules[currDateInt] = scheduleItems
            scheduleViewController.currentScheduleUpdated()
            scheduleViewController.saveSchedules()
        }
        flashItems(itemsToFlash: itemsToFullGreen, for: 2, color: .green)
        itemsToFullGreen = []
        flashItems(itemsToFlash: itemsToGreen, for: 1, color: .green)
        itemsToGreen = []
        flashItems(itemsToFlash: itemsToRed, for: 1, color: .red)
        itemsToRed = []
        deFlashItems(itemsToFlash: scheduleItems, for: 0)
        deFlashItems(itemsToFlash: scheduleItems, for: 1)
        deFlashItems(itemsToFlash: scheduleItems, for: 2)
    }
    func normalizeTFLengths() {
        /*
        var largestLength: CGFloat = 0.0
        for i in tableView.visibleCells {
            let cell = i as! ScheduleTableViewCell
            if cell.startTimeTF.frame.width > largestLength {
                largestLength = cell.startTimeTF.frame.width
            }
        }
        for i in tableView.visibleCells {
            let cell = i as! ScheduleTableViewCell
            cell.startTimeTF.frame = CGRect(x: cell.startTimeTF.frame.minX, y: cell.startTimeTF.frame.minY, width: largestLength, height: cell.startTimeTF.frame.height)
        }
    */
    }
    func updateFromSVC() {
        recalculateTimesBasic()
        tableView.reloadData()
        currDateInt = scheduleViewController.selectedDateInt ?? currDateInt
        if currDateInt == scheduleViewController.dateToHashableInt(date: Date()), let scrollPosition = loadScrollPosition() {
            scrollToTop(indexPath: scrollPosition)
        }
        recalculateTimes(with: nil)
        var rows: [IndexPath] = []
        for i in 0..<scheduleItems.count {
            rows.append(IndexPath(i))
        }
        tableView.reloadRows(at: rows, with: .none)
        tableView.reloadData()
        normalizeTFLengths()
        unhighlightAllCells()
        highlightCurrCell()
    }
    func mergeSameName() {
        var p: ScheduleItem?
        var i = 0
        while i < scheduleItems.count {
            let curr = scheduleItems[i]
            if let prev = p {
                if curr.taskName == prev.taskName {
                    if curr.taskName.range(of: "New Item *\\d*", options: .regularExpression, range: nil, locale: nil) == nil && ((curr.locked && prev.locked) || (!curr.locked && !prev.locked)) {
                        for k in 0..<itemsToFullGreen.count {
                            if itemsToFullGreen[k] === curr || itemsToFullGreen[k] === prev {
                                itemsToFullGreen.remove(at: k)
                                break
                            }
                        }
                        prev.duration += curr.duration
                        scheduleItems.remove(at: i)
                        tableView.deleteRows(at: [IndexPath(i)], with: .none)
                        i -= 1
                        itemsToGreen.append(prev)
                    }
                }
            }
            i += 1
            p = curr
        }
    }
    //inserts an item at the given start time, handling the item in the old spot by the user's insertOption
    //returns row inserted in
    func insertItem(item: ScheduleItem, newStartTime: Int) -> [ScheduleItem] {
        let insertOption = appDelegate.userSettings.insertOption
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
                if (diff > 0) {
                    itemsToRed.append(prev)
                }
            }
            
            if(prevRow >= 0 && insertOption == .split && diff > 0) {
                splitItem = ScheduleItem(name: prev.taskName, duration: diff, startTime: item.startTime! + item.duration)
                scheduleItems.insert(splitItem, at: prevRow + 2)
                itemsToFullGreen.append(splitItem)
            }
            
        }
        
        return scheduleItems
    }
    /*
    //MARK: Persist Data
    func loadScheduleData() -> [ScheduleItem]?{
        return NSKeyedUnarchiver.unarchiveObject(withFile: AppDelegate.DocumentsDirectory.appendingPathComponent(Paths.currentSchedule).path) as? [ScheduleItem]
    }
    
    func saveScheduleData() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(scheduleItems, toFile: AppDelegate.DocumentsDirectory.appendingPathComponent(Paths.currentSchedule).path)
        if isSuccessfulSave {
            os_log("Saving scheduleItems was successful", log: OSLog.default, type: .debug)
        }
        else {
            os_log("Failed to save scheduleItems...", log: OSLog.default, type: .debug)
        }
    }
    */
    
    
 
    
    
    func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }
    
     // Override to support editing the table view.
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            scheduleItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            update()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
     }
     
     // Override to support rearranging the table view.
     func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
    //MARK: Helper functions
    func getCurrentDurationFromMidnight() -> Int {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        return hour * 3600 + minutes * 60 + seconds
    }
    //MARK: Outer functions
    func addButtonPressed() {
        var newTask: ScheduleItem!
        
        if testingMode {
            newTask = ScheduleItem(name: "\(scheduleItems.count + 1)", duration: userSettings.defaultDuration, locked: false)
        }
        else { newTask = ScheduleItem(name: "\(userSettings.defaultName)", duration: userSettings.defaultDuration, locked: false) }
        newTask.startTime = userSettings.defaultStartTime
        scheduleItems.append(newTask)
        
        tableView.insertRows(at: [IndexPath(scheduleItems.count - 1)], with: .none)
       
        update()
        let indexPath = IndexPath(self.scheduleItems.count - 1)
        self.scrollToBottom(indexPath: IndexPath(self.scheduleItems.count - 1))
        tableView.reloadData()
        self.scheduleViewController.schedulesEdited.insert(self.currDateInt)
        if let tf = self.tableView.cellForRow(at: indexPath) as? ScheduleTableViewCell {
            //tf.taskNameTF.becomeFirstResponder()
            /*
            var scrollPoint = CGPoint(x: 0.0, y: tf.startTimeTF.frame.origin.y)
            scrollPoint = tableView.convert(scrollPoint, from: tf)
            tableView.setContentOffset(CGPoint(x: 0.0, y: tableView.contentOffset.y), animated: true)
            */
          

            tf.startTimeTF.backgroundColor = UIColor.white
            tf.durationTF.backgroundColor = UIColor.white
            tf.backgroundColor = UIColor.white
        } else {
            
        }
        self.shouldSelectLast = true
    }
  
    
    
    
    func scrollToRowAfter(at row: Int) {
        
        //tableView.scrollToRow(at: IndexPath(row + 1), at: .none, animated: true)
        
    }
    func scrollToBottom(indexPath: IndexPath){
        if let ip = tableView.indexPathsForVisibleRows {
            prevScrollPos = ip[0]
        }
        DispatchQueue.main.async {
            self.tableView.scrollToRow(at: IndexPath(indexPath.row + 1), at: .bottom, animated: true)
        }
    }
    func scrollToTop(indexPath: IndexPath){
        DispatchQueue.main.async {
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    @objc func highlightCurrCell() {
        unhighlightAllCells()
        if scheduleViewController.tutorialStep == 0 {
            if scheduleViewController.selectedDateInt ?? scheduleViewController.currDateInt == scheduleViewController.dateToHashableInt(date: Date()) {
                for cell in tableView.visibleCells where cell is ScheduleTableViewCell  {
                    let sCell = (cell as! ScheduleTableViewCell)
                    let scheduleItem = sCell.scheduleItem!
                    if let startTime = scheduleItem.startTime {
                        let currentTime = getCurrentDurationFromMidnight()
                        
                        if startTime <= currentTime && startTime + scheduleItem.duration > currentTime  {
                            let bgColorView = UIView()
                            //bgColorView.backgroundColor = UIColor(red: 76.0/255.0, green: 161.0/255.0, blue: 255.0/255.0, alpha: 1.0)
                            let orig = appDelegate.userSettings.themeColor
                            //bgColorView.backgroundColor = tintOf(color: orig, tintFactor: 1/3)
                            //bgColorView.backgroundColor = orig.lighter(by: 10.0)
                           
                            //let gl = Colors().gl!
                            let contentView = sCell.subviews[0]
                            contentView.backgroundColor = orig.withAlphaComponent(0.15)
                            //gl.frame = CGRect(origin: .zero, size: contentView.frame.size)
                            //contentView.layer.addSublayer(gl)
                            
                            /*
                            sCell.addSubview(bgColorView)
                            let leftConstraint = NSLayoutConstraint(item:bgColorView, attribute: .leading, relatedBy: .equal, toItem: sCell.startTimeTF, attribute: .leading, multiplier: 1.0, constant: -5).isActive = true
                            let rightConstraint = NSLayoutConstraint(item:bgColorView, attribute: .trailing, relatedBy: .equal, toItem: sCell.startTimeTF, attribute: .trailing, multiplier: 1.0, constant: 5).isActive = true
                            sCell.sendSubview(toBack: bgColorView)
 */
 
                        }
                        else {
                            let whiteColorView = UIView()
                            whiteColorView.backgroundColor = .white
                            whiteColorView.layer.masksToBounds = true
                            sCell.backgroundView = whiteColorView
                            /*
                            sCell.addSubview(whiteColorView)
                            let leftConstraint = NSLayoutConstraint(item:whiteColorView, attribute: .leading, relatedBy: .equal, toItem: sCell.startTimeTF, attribute: .leading, multiplier: 1.0, constant: -5).isActive = true
                            let rightConstraint = NSLayoutConstraint(item:whiteColorView, attribute: .trailing, relatedBy: .equal, toItem: sCell.startTimeTF, attribute: .trailing, multiplier: 1.0, constant: 5).isActive = true
                            
                            sCell.sendSubview(toBack: whiteColorView)
                            */
                            
                        }
                    }
                }
            }
        }
    }
    func unhighlightAllCells() {
        for cell in tableView.visibleCells where cell is ScheduleTableViewCell {
            let whiteColorView = UIView()
            whiteColorView.backgroundColor = .white
            whiteColorView.layer.masksToBounds = true
            (cell as! ScheduleTableViewCell).backgroundView = whiteColorView
        }
    }
    
    //MARK: UIScrollViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        unhighlightAllCells()
    }
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        scrollingStopped()
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate) {
            scrollingStopped()
        }
        normalizeTFLengths()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollingStopped()
    }
    func scrollingStopped() {
        if let tf = self.tableView.cellForRow(at: IndexPath(self.scheduleItems.count - 1)) as? ScheduleTableViewCell {
            
            tf.startTimeTF.backgroundColor = UIColor.white
            tf.durationTF.backgroundColor = UIColor.white
            tf.backgroundColor = UIColor.white
        }
        if currDateInt == scheduleViewController.dateToHashableInt(date: Date()) {
            saveScrollPosition()
        }
        highlightCurrCell()
        normalizeTFLengths()
    }
    
    func tintOf(color: UIColor, tintFactor: Double) -> UIColor {
        let components = color.components
        let currG = components.green
        let currB = components.blue
        let currR = components.red
        
        let newG = currG + (1 - currG) * tintFactor
        let newB = currB + (1 - currB) * tintFactor
        let newR = currR + (1 - currR) * tintFactor
        return UIColor(red: CGFloat(newR), green: CGFloat(newG), blue: CGFloat(newB), alpha: CGFloat(components.alpha))
    }
    
}
extension UIColor {
    var coreImageColor: CIColor {
        return CIColor(color: self)
    }
    var components: (red: Double, green: Double, blue: Double, alpha: Double) {
        let coreImageColor = self.coreImageColor
        return (Double(coreImageColor.red), Double(coreImageColor.green), Double(coreImageColor.blue), Double(coreImageColor.alpha))
    }
}
extension UIColor {
    func lighter(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    func darker(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    func adjust(by percentage:CGFloat=30.0) -> UIColor? {
        var r:CGFloat=0, g:CGFloat=0, b:CGFloat=0, a:CGFloat=0;
        if(self.getRed(&r, green: &g, blue: &b, alpha: &a)){
            return UIColor(red: min(r + percentage/100, 1.0),
                           green: min(g + percentage/100, 1.0),
                           blue: min(b + percentage/100, 1.0),
                           alpha: a)
        }else{
            return nil
        }
    }
    
}
class Colors {
    var gl:CAGradientLayer!
    
    init() {
        let colorTop = UIColor(red: 192.0 / 255.0, green: 38.0 / 255.0, blue: 42.0 / 255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 35.0 / 255.0, green: 2.0 / 255.0, blue: 2.0 / 255.0, alpha: 1.0).cgColor
        
        self.gl = CAGradientLayer()
        self.gl.colors = [colorTop, colorBottom]
        self.gl.locations = [0.0, 1.0]
    }
}
