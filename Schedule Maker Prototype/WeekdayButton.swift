//
//  CustomButton.swift
//  Schedule Maker Prototype
//
//  Created by Albert Wu on 12/31/17.
//  Copyright © 2017 Old Friend. All rights reserved.
//

import UIKit

class WeekdayButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var isPressed: Bool = false {
        didSet {
            backgroundColor = isPressed ? .green : .blue
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    init(){
        super.init(frame: .zero)
        setup()
        
    }
    func setup(){
        self.backgroundColor = .blue
        self.tintColor = .white
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.borderWidth = 1.5
        self.layer.cornerRadius = 5.0;
        self.translatesAutoresizingMaskIntoConstraints = false
        
    }
}
