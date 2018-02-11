
//
//  IAPViewController.swift
//  Schedule Maker Prototype
//
//  Created by Albert Wu on 2/5/18.
//  Copyright © 2018 Old Friend. All rights reserved.
//

import UIKit


class IAPViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        IAPHandler.shared.fetchAvailableProducts()
        IAPHandler.shared.purchaseStatusBlock = {[weak self] (type) in
            guard let strongSelf = self else{ return }
            if type == .purchased {
                let alertView = UIAlertController(title: "", message: type.message(), preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                    
                })
                alertView.addAction(action)
                strongSelf.present(alertView, animated: true, completion: nil)
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
        let alertView = UIAlertController(title: "Confirm Your In-App Purchase", message: "Do you want to buy Flux Plus for $2.99?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Buy", style: .default, handler: { (alert) in
            print("purchased")
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (alert) in
             print("canceled")
        })
        alertView.addAction(okAction)
        alertView.addAction(cancelAction)
        self.present(alertView, animated: true, completion: nil)
    }
}
