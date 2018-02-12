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
extension IndexPath {
    init(_ row: Int) {
        self.init(row: row, section: 0)
    }
}
extension UIView {
    func isScrolling() -> Bool {
        
        if let scrollView = self as? UIScrollView {
            if (scrollView.isDragging || scrollView.isDecelerating) {
                return true
            }
        }
        
        for subview in self.subviews {
            if ( subview.isScrolling()) {
                return true
            }
        }
        return false
    }
    func waitTillDoneScrolling (completion: @escaping () -> Void) {
        var isMoving = true
        DispatchQueue.global(qos: .background).async {
            while isMoving == true {
                isMoving = self.isScrolling()
            }
            DispatchQueue.main.async {
                completion()}
            
        }
    }
    
}
extension UIButton {
    func setSquareBorder(color: UIColor) {
        self.layer.cornerRadius = 2
        self.layer.borderWidth = 0.7
        self.layer.borderColor = color.cgColor
        self.contentEdgeInsets = UIEdgeInsets(top: 2, left: 3, bottom: 2, right: 3)
    }
}

