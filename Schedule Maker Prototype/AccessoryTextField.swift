//
//  AccessoryTextField.swift
//  Schedule Maker Prototype
//
//  Created by Albert Wu on 1/8/18.
//  Copyright © 2018 Old Friend. All rights reserved.
//

import UIKit

protocol AccessoryTextFieldDelegate{
    func textFieldCustomButtonPressed(_ sender: UITextField)
    func textFieldCancelButtonPressed(_ sender: UITextField)
    func textFieldDoneButtonPressed(_ sender: UITextField)
}

class AccessoryTextField: UITextField {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var accessoryDelegate: AccessoryTextFieldDelegate?
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func addButtons(customString: String?) {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancel: UIBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(self.cancelButtonPressed))
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonPressed))
        var items:[UIBarButtonItem] = []
        if let customText = customString {
            let customButton: UIBarButtonItem = UIBarButtonItem(title: customText, style: .plain, target: self, action: #selector(self.customButtonPressed))
            items = [cancel, customButton, done]
        }
        else { items = [cancel, flexSpace, done] }
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
   
    }
    @objc func cancelButtonPressed() {
        accessoryDelegate?.textFieldCancelButtonPressed(self)
    }
    @objc func doneButtonPressed() {
        
        accessoryDelegate?.textFieldDoneButtonPressed(self)
    }
    @objc func customButtonPressed() {
        accessoryDelegate?.textFieldCustomButtonPressed(self)
    }
    
}

