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

class ScheduleTableViewController: UITableViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let userSettings = (UIApplication.shared.delegate as! AppDelegate).userSettings
    var sharedDefaults: UserDefaults!
    var cellSnapshot: UIView?
    var initialIndexPath: IndexPath? = nil
    var isAnyLockedItems: Bool = false
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    
    
    
    var scheduleViewController: ScheduleViewController!
    
    var scheduleItems: [ScheduleItem] = [ScheduleItem(name: "1", duration: 30 * 60)]
    var origLockedItems: [ScheduleItem] = []
    var currDateInt = 0
    
    //MARK: Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        sharedDefaults = UserDefaults(suiteName: "group.9P3FVEPY7V.group.AlbertWu.ScheduleMakerPrototype")!
        //update()
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(highlightCurrCell), userInfo: nil, repeats: true)
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
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if let scrollPosition = loadScrollPosition() {
            tableView.setContentOffset(scrollPosition, animated: false)
        }
        update()
        
    }
    
    //MARK: Drag and Drop Table View Cell Functions
    func addLongPressGesture() {
        
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressGesture(sender:)))
       
        tableView.addGestureRecognizer(longpress)
        
    }
    func quickReloadCellTimes() {
        for path in tableView.indexPathsForVisibleRows! {
            let row = path.row
            let scheduleItem = scheduleItems[row]
            let cell = tableView.cellForRow(at: path) as! ScheduleTableViewCell
            cell.startTimeTF.text = cell.timeDescription(durationSinceMidnight: scheduleItem.startTime!)
            cell.durationTF.text = cell.durationDescription(duration: scheduleItem.duration)
            cell.row = row
        }
        highlightCurrCell()
    }
    func quickReloadCells() {
            for path in tableView.indexPathsForVisibleRows! {
                let row = path.row
                if row < scheduleItems.count{
                    let scheduleItem = scheduleItems[row]
                    if let cell = tableView.cellForRow(at: path) as? ScheduleTableViewCell {
                        cell.startTimeTF.text = cell.timeDescription(durationSinceMidnight: scheduleItem.startTime!)
                        cell.durationTF.text = cell.durationDescription(duration: scheduleItem.duration)
                        cell.lockButton.setTitle(scheduleItem.locked ? "🔒" : "🌀",for: .normal)
                        cell.taskNameTF.text = scheduleItem.taskName
                        cell.row = row
                    }
                }
            }
            highlightCurrCell()
    }

    
    @objc func onLongPressGesture(sender: UILongPressGestureRecognizer) {
        
        let locationInView = sender.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: locationInView)
        
        if sender.state == .began {
            origLockedItems = []
            for scheduleItem in scheduleItems {
                if scheduleItem.locked {
                    
                    isAnyLockedItems = true
                    origLockedItems.append(scheduleItem.deepCopy())
                }
            }
            if indexPath != nil {
                initialIndexPath = indexPath!
                let cell = tableView.cellForRow(at: indexPath!)
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
        } else if sender.state == .changed {
            var center = cellSnapshot!.center
            center.y = locationInView.y
            cellSnapshot?.center = center
            
            if ((indexPath != nil) && (indexPath != initialIndexPath)) {
                
               
                let temp = scheduleItems[indexPath!.row]
                scheduleItems[indexPath!.row] = scheduleItems[initialIndexPath!.row]
                scheduleItems[initialIndexPath!.row] = temp
                tableView.moveRow(at: initialIndexPath!, to: indexPath!)
                
                if indexPath?.row == 0 && scheduleItems.count > 1 && scheduleItems[0].startTime != nil{
                    scheduleItems[0].startTime! = scheduleItems[1].startTime! - scheduleItems[0].duration
                }
                recalculateTimesBasic()
                quickReloadCellTimes()
                let cell = tableView.cellForRow(at: indexPath!)!
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
        } else if sender.state == .ended {
            let cell = tableView.cellForRow(at: initialIndexPath!) as? ScheduleTableViewCell
            if initialIndexPath?.row == 0 && scheduleItems.count > 1 && scheduleItems[0].startTime != nil{
                scheduleItems[0].startTime! = scheduleItems[1].startTime! - scheduleItems[0].duration
            }
            cell?.isHidden = false
            cell?.alpha = 0.0
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
            
            //update
            //recalculateTimesWith(origLockedItems: origLockedItems)
            recalculateTimes(with: origLockedItems)
            tableView.reloadData()
            scheduleViewController.schedules[currDateInt] = scheduleItems
            //scheduleViewController.saveSchedule(date: currDateInt, scheduleItems: scheduleItems)
            highlightCurrCell()
            scheduleViewController.currentScheduleUpdated()
        }
        
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
        var scheduleItemsC = self.scheduleItems
        var i = 0
        var currStartTime = 0
        if scheduleItemsC.count > 0 {
            currStartTime = scheduleItemsC[0].startTime!
        }
        while i < scheduleItemsC.count {
            let task = scheduleItemsC[i]
            if task.locked {
                scheduleItemsC.remove(at: i)
                print("DELETE")
            }
            else {
                task.startTime = currStartTime
                currStartTime += task.duration
                i += 1
                
            }
        }
        
        return scheduleItemsC
    }
    func getLockedItems() -> [ScheduleItem] {
        var lockedItems: [ScheduleItem] = []
        for i in scheduleItems {
            if i.locked {
                lockedItems.append(i)
                print("ADD")
            }
            
        }
        return lockedItems
    }
    func recalculateTimes(with lockedTasksP: [ScheduleItem]?) {
        
        var cleanedSchedule = deletedLockedItemsAndOrdered()
        var lockedTasks: [ScheduleItem] = []
        if lockedTasksP == nil {
            lockedTasks = getLockedItems()
        }
        else {
            lockedTasks = lockedTasksP!
        }
        for i in lockedTasks {
            print(i.taskName)
            print("SHOULD BE\(cleanedSchedule.count)")
            cleanedSchedule = insertItem(item: i, newStartTime: i.startTime!, sItemsP: cleanedSchedule)
            print("NOW\(cleanedSchedule.count)")
            cleanedSchedule = recalculateTimesBasic(with: cleanedSchedule)
           
        }
        self.scheduleItems = cleanedSchedule
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
        let offset = tableView.contentOffset
        print("scroll pos saved: \(offset.y)")
        sharedDefaults.set(NSKeyedArchiver.archivedData(withRootObject: offset), forKey: Paths.scrollPosition)
    }
    
    
    func loadScrollPosition() -> CGPoint? {
        if let data = sharedDefaults.object(forKey: Paths.scrollPosition) as? Data {
            
            let unarcher = NSKeyedUnarchiver(forReadingWith: data)
            
            return unarcher.decodeObject(forKey: "root") as? CGPoint
        }
        return nil
    }
  
    
  

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return scheduleItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! ScheduleTableViewCell
        cell.tableViewController = self
        cell.row = indexPath.row
        cell.scheduleItem = scheduleItems[indexPath.row]
        cell.selectionStyle = .none
        
        cell.layer.borderColor = appDelegate.userSettings.themeColor.cgColor
        cell.layer.borderWidth = 0.1
        
        return cell
    }
   
            
    
        
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 65
    }
    /*
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return header
    }*/
    
    
    
    
  
    
    //MARK: Update Data
    func update() {
        //when a ScheduleItem's duration is changed, or when the first ScheduleItem's startTime is changed,
        //recalculate all startTimes based on the first startTime and each scheduleItem's duration
        recalculateTimes(with: nil)
        /*
        var rows: [IndexPath] = []
        for i in 0..<scheduleItems.count {
            rows.append(IndexPath(i))
        } */
        //tableView.reloadRows(at: rows, with: .none)
        tableView.reloadData()
        //quickReloadCells()
        //tableView.reloadData()
        scheduleViewController.schedules[currDateInt] = scheduleItems
        //scheduleViewController.saveSchedule(date: currDateInt, scheduleItems: scheduleItems)
        highlightCurrCell()
        scheduleViewController.currentScheduleUpdated()
        scheduleViewController.saveSchedules()
 
    }
    func updateFromSVC() {
        tableView.reloadData()
        print("HERE: \(scheduleItems.count)")
        recalculateTimes(with: nil)
        print("THERE: \(scheduleItems.count)")
        var rows: [IndexPath] = []
        for i in 0..<scheduleItems.count {
            rows.append(IndexPath(i))
        }
        tableView.reloadRows(at: rows, with: .none)
        highlightCurrCell()
        
    }
    
    //inserts an item at the given start time, handling the item in the old spot by the user's insertOption
    //returns row inserted in
    func insertItem(item: ScheduleItem, newStartTime: Int, sItemsP: [ScheduleItem]?) -> [ScheduleItem] {
        var sItems:[ScheduleItem] = []
        if sItemsP != nil {
            sItems = sItemsP!
        } else {
            sItems = self.scheduleItems
        }
        let insertOption = appDelegate.userSettings.insertOption
        item.startTime = newStartTime
        
        var prevRow = sItems.count
        //find correct previous item
        swapLoop: while(prevRow >= 0) {
            prevRow -= 1
            if prevRow == -1 || (item.startTime! > sItems[prevRow].startTime! || (item.startTime! == sItems[prevRow].startTime! && insertOption == .extend)) {
                break swapLoop
            }
        }
        //if extending duration, must take "prev prev" item
        if (insertOption == .extend) {
            prevRow -= 1
        }
        
        sItems.insert(item, at: prevRow + 1)
        tableView.insertRows(at: [IndexPath(prevRow + 1)], with: .none)
        
        let lastRow = sItems.count - 1
        let secondLast = lastRow > 0 ? sItems[lastRow - 1] : nil
        if lastRow > 0 && item.startTime! >= secondLast!.startTime! + secondLast!.duration  {
            secondLast!.duration = item.startTime! - secondLast!.startTime!
        }
        else {
            var splitItem: ScheduleItem!
            //let curr = scheduleItems[i+1]
            var diff = 0
            var prev: ScheduleItem!
            if (prevRow >= 0) {
                prev = sItems[prevRow]
                diff = prev.startTime! + prev.duration - item.startTime!
                prev.duration -= diff
                
                
            }
            
            if(prevRow >= 0 && insertOption == .split && diff > 0) {
                splitItem = ScheduleItem(name: prev.taskName, duration: diff, startTime: item.startTime! + item.duration)
                sItems.insert(splitItem, at: prevRow + 2)
                tableView.insertRows(at: [IndexPath(prevRow + 1)], with: .none)
                
            }
            
        }
        return sItems
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
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            scheduleItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            update()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
     }
     
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
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
        
        let newTask = ScheduleItem(name: "\(scheduleItems.count + 1)", duration: 20 * 60, locked: false)
        newTask.startTime = userSettings.defaultStartTime
        scheduleItems.append(newTask)
        recalculateTimes(with: nil)
 
        tableView.reloadData()
       
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
        /*
        for i in 0..<scheduleItems.count {
            let scheduleItem = scheduleItems[i]
            if let startTime = scheduleItem.startTime {
                let currentTime = getCurrentDurationFromMidnight()
                let thisTableView = tableView!
                let indexPath = IndexPath(row: i, section: 0)
                let cell = tableView.cellForRow(at: indexPath)!
                
                if startTime <= currentTime && startTime + scheduleItem.duration > currentTime  {
                    let bgColorView = UIView()
                    bgColorView.backgroundColor = UIColor(red: 76.0/255.0, green: 161.0/255.0, blue: 255.0/255.0, alpha: 1.0)
                    bgColorView.layer.masksToBounds = true
                    cell.backgroundView = bgColorView
                }
                else {
                    let whiteColorView = UIView()
                    whiteColorView.backgroundColor = .white
                    whiteColorView.layer.masksToBounds = true
                    cell.backgroundView = whiteColorView
                }
 
                
            }
        }
 */
        if scheduleViewController.selectedDateInt ?? scheduleViewController.currDateInt == scheduleViewController.dateToHashableInt(date: Date()) {
            for cell in tableView.visibleCells  {
                let scheduleItem = (cell as! ScheduleTableViewCell).scheduleItem!
                if let startTime = scheduleItem.startTime {
                    let currentTime = getCurrentDurationFromMidnight()
                    
                    if startTime <= currentTime && startTime + scheduleItem.duration > currentTime  {
                        let bgColorView = UIView()
                        //bgColorView.backgroundColor = UIColor(red: 76.0/255.0, green: 161.0/255.0, blue: 255.0/255.0, alpha: 1.0)
                        let orig = appDelegate.userSettings.themeColor
                        //bgColorView.backgroundColor = tintOf(color: orig, tintFactor: 1/3)
                        //bgColorView.backgroundColor = orig.lighter(by: 10.0)
                        bgColorView.backgroundColor = orig.withAlphaComponent(0.3)
                        
                        bgColorView.layer.masksToBounds = true
                        (cell as! ScheduleTableViewCell).backgroundView = bgColorView
                    }
                    else {
                        let whiteColorView = UIView()
                        whiteColorView.backgroundColor = .white
                        whiteColorView.layer.masksToBounds = true
                        (cell as! ScheduleTableViewCell).backgroundView = whiteColorView
                    }
                }
            }
        }
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

