//
//  Extensions.swift
//  Schedule Maker Prototype
//
//  Created by Albert Wu on 11/25/17.
//  Copyright © 2017 Old Friend. All rights reserved.
//

import Foundation
import UIKit

extension Date {
    
    var weekday: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).uppercased()
    }
    var month: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        return dateFormatter.string(from: self).uppercased()
    }
    var day: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter.string(from: self).uppercased()
    }
    func format(format:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  format
        return dateFormatter.string(from: self).uppercased()
    }
}
extension UIBarButtonItem {
    func addTarget(target: AnyObject, action: Selector) {
        self.target = target
        self.action = action
    }
}
