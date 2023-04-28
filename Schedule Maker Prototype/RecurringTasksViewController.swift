//
//  RecurringTasksViewController.swift
//  Schedule Maker Prototype
//
//  Created by Albert Wu on 12/30/17.
//  Copyright © 2017 Old Friend. All rights reserved.
//

import UIKit

class RecurringTasksViewController: BaseViewController {
  
  
  @IBOutlet weak var backButton: UIBarButtonItem!
  
  @IBOutlet weak var addRTaskButton: UIButton!
  var rtvc:RecurringTasksTableViewController!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    if(segue.identifier == "RTasksEmbedSegue") {
      rtvc = segue.destination as! RecurringTasksTableViewController
      rtvc.vc = self
    }
  }
  
  @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
    rtvc.saveRTasks()
    dismiss(animated: true, completion: nil)
  }
  
  //MARK: Actions
  @IBAction func addRTaskButtonPressed(_ sender: UIButton) {
    rtvc.addRTask()
  }
  
}
