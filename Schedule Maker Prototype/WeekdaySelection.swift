//
//  WeekdaySelection.swift
//  Schedule Maker Prototype
//
//  Created by Albert Wu on 12/28/17.
//  Copyright © 2017 Old Friend. All rights reserved.
//

import UIKit

class WeekdaySelection: UIStackView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    enum Weekday: Int {
        case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    }
    
    var weekdayString: [String] = ["M", "T", "W", "TH", "F", "S", "SU"]
    var weekdayButtons: [UIButton] = []
    var chosenWeekdays: Set = Set<Int>()
    
    //MARK: Initializations
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    private func setupButtons() {
        
        for i in 0..<7 {
            // Create the button
            let button = UIButton()
            button.backgroundColor = UIColor.red
            
            // Add constraints
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 50).isActive = true
            button.widthAnchor.constraint(equalToConstant: 50).isActive = true
            
            // Setup the button action
            button.addTarget(self, action: #selector(WeekdaySelection.weekdayButtonTapped(button:)), for: .touchUpInside)
            button.setTitle(weekdayString[i], for: .normal)
            // Add the button to the stack
            addArrangedSubview(button)
            
            // Add the new button to the rating button array
            weekdayButtons.append(button)
        }
    }
    @objc func weekdayButtonTapped(button: UIButton) {
        let index = weekdayButtons.index(of: button)!
        if(button.isHighlighted) {
            chosenWeekdays.remove(index)
        }
        else {
            chosenWeekdays.insert(index)
        }
        button.isHighlighted = !button.isHighlighted
        
    }
}
