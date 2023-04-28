//
//  RecurringTasksTableViewController.swift
//  Schedule Maker Prototype
//
//  Created by Albert Wu on 12/30/17.
//  Copyright © 2017 Old Friend. All rights reserved.
//

import UIKit

class RecurringTasksTableViewController: UITableViewController {
  var vc: RecurringTasksViewController!
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  let sharedDefaults = UserDefaults(suiteName: "group.AlbertWu.ScheduleMakerPrototype")!
  var rTasks: [ScheduleItem] = []
  override func viewDidLoad() {
    super.viewDidLoad()
    appDelegate.recurringTasksTableViewController = self
    if let savedRTasks = RecurringTasksTableViewController.loadRTasks() {
      rTasks = savedRTasks
    }
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem
    tableView.rowHeight = 90
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  func addRTask() {
    let rTask = ScheduleItem(name: "Recurring Task", duration: 30 * 60, locked: true)
    rTask.recurDays = Set<Int>()
    rTasks.append(rTask)
    
    update()
  }
  func update() {
    tableView.reloadData()
    saveRTasks()
  }
  // MARK: - Table view data source
  override func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return rTasks.count
  }
  
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "rTaskCell", for: indexPath) as! RecurringTaskTableViewCell
    cell.tvcontroller = self
    cell.selectionStyle = .none
    let item = rTasks[indexPath.row]
    
    cell.scheduleItem = item
    // Configure the cell...
    
    return cell
  }
  func saveRTasks() {
    
    NSKeyedArchiver.setClassName("ScheduleItem", for: ScheduleItem.self)
    sharedDefaults.set(NSKeyedArchiver.archivedData(withRootObject: rTasks), forKey: Paths.rTasks)
  }
  
  static func loadRTasks() -> [ScheduleItem]? {
    if let data = UserDefaults(suiteName: "group.AlbertWu.ScheduleMakerPrototype")!.object(forKey: Paths.rTasks) as? Data {
      NSKeyedUnarchiver.setClass(ScheduleItem.self, forClassName: "ScheduleItem")
      let unarcher = NSKeyedUnarchiver(forReadingWith: data)
      return unarcher.decodeObject(forKey: "root") as? [ScheduleItem]
    }
    return nil
  }
  
  /*
   // Override to support conditional editing of the table view.
   override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
   // Return false if you do not want the specified item to be editable.
   return true
   }
   */
  
  /*
   // Override to support editing the table view.
   override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
   if editingStyle == .delete {
   // Delete the row from the data source
   tableView.deleteRows(at: [indexPath], with: .fade)
   } else if editingStyle == .insert {
   // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
   }    
   }
   */
  
  /*
   // Override to support rearranging the table view.
   override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
   
   }
   */
  
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
  
}
