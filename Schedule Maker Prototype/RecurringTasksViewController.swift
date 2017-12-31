//
//  RecurringTasksViewController.swift
//  Schedule Maker Prototype
//
//  Created by Albert Wu on 12/30/17.
//  Copyright © 2017 Old Friend. All rights reserved.
//

import UIKit

class RecurringTasksViewController: UIViewController {

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
        if(segue.identifier == "RTaskEmbedSegue") {
            rtvc = segue.destination as! RecurringTasksTableViewController
        }
    }
    

    //MARK: Actions
    @IBAction func addRTaskButtonPressed(_ sender: UIButton) {
        rtvc.addRTask()
    }
}
