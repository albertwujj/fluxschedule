//
//  SettingsViewController.swift
//  Schedule Maker Prototype
//
//  Created by Albert Wu on 11/23/17.
//  Copyright © 2017 Old Friend. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var timeModeSwitch: UISwitch!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.changeStatusBarColor(color: .white)
        navigationController!.setNavigationBarHidden(false, animated: false)
        timeModeSwitch.addTarget(self, action: #selector(timeModeChanged(switchState:)), for: .valueChanged)
        timeModeSwitch.isOn = appDelegate.userSettings.is24Mode
        // Do any additional setup after loading the view.
    }
    override func viewWillDisappear(_ animated: Bool) {
        AppDelegate.changeStatusBarColor(color: .blue)
        self.navigationController!.setNavigationBarHidden(true, animated: true)
    }
    @objc func timeModeChanged(switchState: UISwitch) {
            appDelegate.userSettings.is24Mode = switchState.isOn
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        print("back!!")
        self.navigationController!.popViewController(animated: true)
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
