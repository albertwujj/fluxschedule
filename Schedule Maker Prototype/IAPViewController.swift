
//
//  IAPViewController.swift
//  Schedule Maker Prototype
//
//  Created by Albert Wu on 2/5/18.
//  Copyright © 2018 Old Friend. All rights reserved.
//

import UIKit


class IAPViewController: BaseViewController {
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  var userSettings: Settings!
  @IBOutlet weak var fluxPlusButton: UIButton!
  @IBOutlet weak var subButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    userSettings = appDelegate.userSettings
    
    fluxPlusButton.setSquareBorder(color: UIColor.blue.withAlphaComponent(0.7))
    IAPHandler.shared.fetchAvailableProducts()
    IAPHandler.shared.purchaseStatusBlock = {[weak self] (type, trans) in
      guard let strongSelf = self else{ return }
      if type == .disabled {
        let alertView = UIAlertController(title: "", message: type.message(), preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
          
        })
        alertView.addAction(action)
        strongSelf.present(alertView, animated: true, completion: nil)
      }
      
      if type == .purchased || type == .restored {
        if trans!.payment.productIdentifier == "9P3FVEPY7V.fluxplus" {
          strongSelf.userSettings.fluxPlus = true
          
          let svc = strongSelf.appDelegate.svc!
          if(svc.tutorialStep == .done) {
            //svc.tutorialStep = .lock
            svc.appDelegate.svc.checkAddTutorial()
          }
          /*
           if(svc.tutorialStep == Tut(5) {
           svc.tutorialStep = 3
           svc.tableViewController.scheduleItems = svc.tutorialStepDrag
           svc.tableViewController.updateFromSVC()
           svc.tutorialNextButton.setTitle("Done!", for: .normal)
           svc.tutorialNextButton.layer.borderColor = UIColor.blue.withAlphaComponent(0.1).cgColor
           svc.tutorialNextButton.isEnabled = false
           }*/
          svc.tutorialStepExample = [ScheduleItem(name: "Morning routine", duration: 45 * 60, startTime: 7 * 3600), ScheduleItem(name: "Check Facebook", duration: 15 * 60), ScheduleItem(name: "Go work", duration: 8 * 3600, locked: true), ScheduleItem(name: "Donuts with co-workers", duration: 30 * 60, locked: true), ScheduleItem(name: "Respond to emails", duration: 20 * 60), ScheduleItem(name: "Work on side-project", duration: 45 * 60), ScheduleItem(name: "Pick up Benjamin", duration: 30 * 60)]
          svc.appDelegate.svc.saveTutorialStep()
          svc.appDelegate.saveUserSettings()
        } else if trans!.payment.productIdentifier == "9P3FVEPY7V.sub" {
          strongSelf.userSettings.subs = true
        }
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
