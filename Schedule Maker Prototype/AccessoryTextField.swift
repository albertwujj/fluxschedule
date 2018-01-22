//
//  AccessoryTextField.swift
//  Schedule Maker Prototype
//
//  Created by Albert Wu on 1/8/18.
//  Copyright © 2018 Old Friend. All rights reserved.
//

import UIKit

protocol AccessoryTextFieldDelegate{
    func textFieldContainerButtonPressed(_ sender: AccessoryTextField)
    func textFieldCancelButtonPressed(_ sender: AccessoryTextField)
    func textFieldDoneButtonPressed(_ sender: AccessoryTextField)
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
    var doneButton: UIBarButtonItem!
    
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    public func addButtons(customString: String?) {
        addButtons(customString: customString, customButton: nil)
    }
    
    public func addButtons(customString: String?, customButton: UIButton?) {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancel: UIBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(self.cancelButtonPressed))
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonPressed))
        var items:[UIBarButtonItem] = []
        if let customText = customString {
            let containerButton: UIBarButtonItem = UIBarButtonItem(title: customText, style: .done, target: self, action: #selector(self.containerButtonPressed))
            items = [cancel, flexSpace, containerButton, flexSpace, done]
        } else if let givenButton = customButton{
            let containerButton = UIBarButtonItem(customView: givenButton)
            items = [cancel, flexSpace, containerButton, flexSpace, done]
        }
        else { items = [cancel, flexSpace, done] }
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        self.inputAccessoryView = doneToolbar
        self.doneButton = done
    }
    @objc func cancelButtonPressed() {
        accessoryDelegate?.textFieldCancelButtonPressed(self)
    }
    @objc func doneButtonPressed() {
        
        accessoryDelegate?.textFieldDoneButtonPressed(self)
    }
    @objc func containerButtonPressed() {
        accessoryDelegate?.textFieldContainerButtonPressed(self)
    }
    override func caretRect(for position: UITextPosition) -> CGRect {
        return CGRect.zero
    }
}

