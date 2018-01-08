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
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    
    
    var scheduleViewController: ScheduleViewController!
    var scheduleItems: [ScheduleItem] = [ScheduleItem(name: "Task", duration: 30 * 60)]
    var currDateInt = 0
    
    //MARK: Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        update()
        Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(highlightCurrCell), userInfo: nil, repeats: true)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        update()
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        return 50
    }
    /*
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return header
    }*/
    
    
    
    
  
    
    //MARK: Update Data
    func update() {
        //when a ScheduleItem's duration is changed, or when the first ScheduleItem's startTime is changed,
        //recalculate all startTimes based on the first startTime and each scheduleItem's duration
        recalculateTimes()
        tableView.reloadData()
        scheduleViewController.schedules[currDateInt] = scheduleItems
        //scheduleViewController.saveSchedule(date: currDateInt, scheduleItems: scheduleItems)
        highlightCurrCell()
        scheduleViewController.currentScheduleUpdated()
        
    }
    func updateFromSVC() {
        recalculateTimes()
        tableView.reloadData()
        highlightCurrCell()
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
                
                
            }
            
            if(prevRow >= 0 && insertOption == .split && diff != 0) {
                splitItem = ScheduleItem(name: prev.taskName, duration: diff, startTime: item.startTime! + item.duration)
                scheduleItems.insert(splitItem, at: prevRow + 2)
            }
            
        }
        
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
        scheduleItems.append(ScheduleItem(name: "\(scheduleItems.count + 1)", duration: 20 * 60, locked: false))
        update()
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
                    bgColorView.backgroundColor = orig.withAlphaComponent(0.8)
                    print("FUCKER: \(String(describing: bgColorView.backgroundColor?.components.alpha))")
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

