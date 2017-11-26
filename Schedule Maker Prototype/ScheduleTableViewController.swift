//
//  ScheduleTableViewController.swift
//  Schedule Maker Prototype
//
//  Created by Albert Wu on 11/7/17.
//  Copyright © 2017 Old Friend. All rights reserved.
//

import os.log
import UIKit

class ScheduleTableViewController: UITableViewController {

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
        if scheduleItems.count != 0 {
            if var currStartTime = scheduleItems[0].startTime {
                for i in scheduleItems {
                    i.startTime = currStartTime
                    currStartTime = currStartTime + i.duration
                    /*
                    let startTextField = self.tableView.subviews[0].subviews[0].subviews[0] if
                    */
                }
            }
            
            
            
        }
        tableView.reloadData()
        scheduleViewController.schedules[currDateInt] = scheduleItems
        scheduleViewController.saveSchedule(date: currDateInt, scheduleItems: scheduleItems)
        scheduleViewController.saveSchedulesData()
        highlightCurrCell()
        
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
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
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
        scheduleItems.append(ScheduleItem(name: "Task", duration: 30 * 60))
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
                    bgColorView.backgroundColor = .blue
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
