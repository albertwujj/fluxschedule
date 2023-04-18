//
//  StreakViewController.swift
//  Schedule Maker Prototype
//
//  Created by Albert Wu on 2/22/18.
//  Copyright © 2018 Old Friend. All rights reserved.
//

import UIKit
import StoreKit

class StreakPopoverViewController: UIViewController {
    let sharedDefaults = UserDefaults(suiteName: "group.9P3FVEPY7V.group.AlbertWu.ScheduleMakerPrototype")!

    @IBOutlet weak var dailyStreakCounter: UILabel!
    @IBOutlet weak var totalDaysCounter: UILabel!

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let tvc = (UIApplication.shared.delegate as! AppDelegate).svc.tableViewController!
    override func viewDidLoad() {
        super.viewDidLoad()

        updateDisplays()
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        if loadBasic(key: "first_view") == nil {
            presentAlert(title: "Daily Stats", message: "Each day you fill out at least 5 tasks is recorded! Have fun!")
            saveBasic(data: true, key: "first_view")
        }
        super.viewDidAppear(animated)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func updateDisplays() {
        let streakStats = tvc.streakStats
        dailyStreakCounter.text = String(calculateDailyStreak(streakStats))
        totalDaysCounter.text = String(calculateTotalDays(streakStats))
    }



    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */



}
