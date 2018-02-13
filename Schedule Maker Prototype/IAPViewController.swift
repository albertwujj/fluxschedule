
//
//  IAPViewController.swift
//  Schedule Maker Prototype
//
//  Created by Albert Wu on 2/5/18.
//  Copyright © 2018 Old Friend. All rights reserved.
//

import UIKit


class IAPViewController: UIViewController {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userSettings: Settings!
    @IBOutlet weak var fluxPlusButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userSettings = appDelegate.userSettings
        
        fluxPlusButton.setSquareBorder(color: UIColor.blue.withAlphaComponent(0.7))
        IAPHandler.shared.fetchAvailableProducts()
        IAPHandler.shared.purchaseStatusBlock = {[weak self] (type) in
            guard let strongSelf = self else{ return }
            if type == .disabled {
                let alertView = UIAlertController(title: "", message: type.message(), preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                    
                })
                alertView.addAction(action)
                strongSelf.present(alertView, animated: true, completion: nil)
            }
            
            if type == .purchased || type == .restored {
                strongSelf.userSettings.fluxPlus = true
                
                let svc = strongSelf.appDelegate.scheduleViewController!
                if(svc.tutorialStep == 0) {
                    svc.tutorialStep = 6
                    svc.appDelegate.scheduleViewController.addTutorial()
                }
                if(svc.tutorialStep == 5) {
                    svc.tutorialStep = 4
                    svc.tableViewController.scheduleItems = svc.tutorialStep4
                    svc.tableViewController.updateFromSVC()
                    svc.tutorialNextButton.setTitle("Done! Now give me an example.", for: .normal)
                    svc.tutorialNextButton.layer.borderColor = UIColor.blue.withAlphaComponent(0.1).cgColor
                    svc.tutorialNextButton.isEnabled = false
                }
                svc.appDelegate.scheduleViewController.saveTutorialStep()
                svc.appDelegate.saveUserSettings()
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func fluxPlusPurchased(_ sender: UIButton) {
        /*
        let alertView = UIAlertController(title: "Confirm Your In-App Purchase", message: "Do you want to buy Flux Plus for $2.99?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Buy", style: ., handler: { (alert) in
             IAPHandler.shared.purchaseMyProduct(index: 0)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert) in
             print("canceled")
        })
        alertView.addAction(okAction)
        alertView.addAction(cancelAction)
        self.present(alertView, animated: true, completion: nil)
 */
        IAPHandler.shared.purchaseMyProduct(index: 0)
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
