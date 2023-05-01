//
//  StreakViewController.swift
//  Schedule Maker Prototype
//
//  Created by Albert Wu on 2/22/18.
//  Copyright © 2018 Old Friend. All rights reserved.
//

import UIKit
import StoreKit

class StreakViewController: BaseViewController {
  let sharedDefaults = UserDefaults(suiteName: "group.9P3FVEPY7V.group.AlbertWu.ScheduleMakerPrototype")!
  @IBOutlet weak var totalWeeksCounter: UILabel!
  @IBOutlet weak var totalDaysCounter: UILabel!
  @IBOutlet weak var weekStreakCounter: UILabel!
  @IBOutlet var dailyStreakCounter: UILabel!
  var streakStats: StreakStats = StreakStats()
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  let tvc = (UIApplication.shared.delegate as! AppDelegate).svc.tableViewController!
  override func viewDidLoad() {
    super.viewDidLoad()
    if let savedStreakStats = tvc.loadStreakStats() {
      streakStats = savedStreakStats
    }
    
    updateDisplays()
    
    // Do any additional setup after loading the view.
  }
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  func updateDisplays() {
    dailyStreakCounter.text = String(calculateDailyStreak(streakStats))
    weekStreakCounter.text = String(calculateWeeklyStreak(streakStats))
    totalDaysCounter.text = String(calculateTotalDays(streakStats))
    totalWeeksCounter.text = String(calculateTotalWeeks(streakStats))
  }
  
  
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
  
  @IBAction func backButtonPressed(_ sender: UIButton) {
    dismiss(animated: true, completion: nil)
  }
}
