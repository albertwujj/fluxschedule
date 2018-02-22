//
//  StreakViewController.swift
//  Schedule Maker Prototype
//
//  Created by Albert Wu on 2/22/18.
//  Copyright © 2018 Old Friend. All rights reserved.
//

import UIKit

class StreakViewController: UIViewController {
    let sharedDefaults = UserDefaults(suiteName: "group.9P3FVEPY7V.group.AlbertWu.ScheduleMakerPrototype")!
    @IBOutlet var dailyStreakCounter: UILabel!
    var streakStats: StreakStats = StreakStats()
    override func viewDidLoad() {
        super.viewDidLoad()
        if let savedStreakStats = loadStreakStats() {
            streakStats = savedStreakStats
        }
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateDisplays()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func updateDisplays() {
        dailyStreakCounter.text = String(calculateDailyStreak(streakStats))
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func saveStreakStats(streakStats:StreakStats) {
        sharedDefaults.set(NSKeyedArchiver.archivedData(withRootObject: streakStats), forKey: Paths.streakStats)
    }
    func loadStreakStats() -> StreakStats? {
        if let data = sharedDefaults.object(forKey: Paths.scrollPosition) as? Data {
            let unarcher = NSKeyedUnarchiver(forReadingWith: data)
            return unarcher.decodeObject(forKey: "root") as? StreakStats
        }
        return nil
    }

}
