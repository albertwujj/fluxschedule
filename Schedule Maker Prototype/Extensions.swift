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

extension UIScrollView {
    
    var pendingContentSize: CGSize {
        var tallSize = contentSize
        tallSize.height = .greatestFiniteMagnitude
        return sizeThatFits(tallSize)
    }
    
    func scrollToBottom(animated: Bool) {
        contentSize = pendingContentSize
        let contentRect = CGRect(origin: .zero, size: contentSize)
        let (bottomSlice, _) = contentRect.divided(atDistance: 1, from: .maxYEdge)
        guard !bottomSlice.isEmpty else { return }
        scrollRectToVisible(bottomSlice, animated: animated)
    }
    
}
extension UIViewController {
    func getStringWeekday(date: Date) -> String  {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: date).uppercased()
    }
    
    func dateDescription(date: Date) -> String {
        let formatter = DateFormatter()
        
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        return formatter.string(from: date)
    }
    func dateToHashableInt(date: Date) -> Int {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let year = calendar.component(.year, from: date)
        //mathematically this will allow consistent conversion from date to int
        return year * 372 + month * 31 + day
    }
    func intToDate(int: Int) -> Date {
        var intMutable = int
        var dC = DateComponents()
        dC.year = intMutable / 372
        intMutable = intMutable % 372
        dC.month = intMutable / 31
        intMutable = intMutable % 31
        dC.day = intMutable
        return Calendar.current.date(from: dC)!
    }
    
    func intDateDescription(int: Int) -> String {
        var intMutable = int
        let year = intMutable / 372
        intMutable = intMutable % 372
        let month = intMutable / 31
        intMutable = intMutable % 31
        let day = intMutable
        return "\(month)/\(day)/\(year)"
    }
    func getCurrDateInt() -> Int {
        return dateToHashableInt(date: Date())
    }
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    func calculateDailyStreak(_ streakStats: StreakStats) -> Int{
        let currDateInt = getCurrDateInt()
        var j = 0
        for i in ((streakStats.markedDays.min() ?? currDateInt) ..< currDateInt).reversed() {
            if !streakStats.markedDays.contains(i) {
                break
            }
            j += 1
        }
        j += streakStats.markedDays.contains(currDateInt).hashValue
        return j
    }
    func getWeekday(_ date: Date) -> Int {
        return Calendar.current.component(.weekday, from: date)
    }
    func calculateTotalDays(_ streakStats: StreakStats)->Int{
        return streakStats.markedDays.count
    }
    func calculateTotalWeeks(_ streakStats: StreakStats) -> Int {
        let currDateInt = getCurrDateInt()
        let currDate = intToDate(int: currDateInt)
        let weekday = getWeekday(currDate)
        var weekCount = 0
        
        var j = 0
        
        var isUnbroken = true;
        for i in ((streakStats.markedDays.min() ?? currDateInt) ... currDateInt - weekday).reversed() {
            if !streakStats.markedDays.contains(i) {
                isUnbroken = false
            }
            j += 1
            if(j == 7) {
                j = 0
                if(isUnbroken) {
                    weekCount += 1
                }
                isUnbroken = true
            }
        }
        return weekCount
    }
    func calculateWeeklyStreak(_ streakStats: StreakStats) -> Int {
        let currDateInt = getCurrDateInt()
        let currDate = intToDate(int: currDateInt)
        let weekday = getWeekday(currDate)
        
        var j = 0
        for i in ((streakStats.markedDays.min() ?? currDateInt) ... currDateInt - weekday).reversed() {
            if !streakStats.markedDays.contains(i) {
                break
            }
            j += 1
        }
        return j / 7
    }
    
    func getCurrentDurationFromMidnight() -> Int {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        return hour * 3600 + minutes * 60 + seconds
    }
    func timeDescription(durationSinceMidnight: Int) -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        let date = Calendar.current.startOfDay(for: Date()).addingTimeInterval(Double(durationSinceMidnight))
        var text = formatter.string(from: date)
        if durationSinceMidnight >= 13 * 3600 {
            text = text + " "
        }
        
        if durationSinceMidnight < 10 * 3600 {
            text = text + " "
        }
        
        return text
        
    }
}

