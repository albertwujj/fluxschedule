//
//  Settings.swift
//  Schedule Maker Prototype
//
//  Created by Albert Wu on 11/24/17.
//  Copyright © 2017 Old Friend. All rights reserved.
//

import UIKit
enum InsertOption: Int {
    case shrink = 0
    case extend = 1
    case split = 2
}

class Settings: NSObject, NSCoding {
    var is24Mode: Bool = false
    var notifDelayTime = 10
    var themeColor:UIColor = .blue
    var insertOption: InsertOption = .shrink
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(is24Mode, forKey: PropertyKey.is24Mode)
        aCoder.encode(notifDelayTime, forKey: PropertyKey.notifDelayTime)
        aCoder.encode(themeColor, forKey: PropertyKey.themeColor)
        aCoder.encode(insertOption.rawValue, forKey: PropertyKey.insertOption)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        self.is24Mode = aDecoder.decodeBool(forKey: PropertyKey.is24Mode)
        self.notifDelayTime = aDecoder.decodeInteger(forKey: PropertyKey.notifDelayTime)
        self.themeColor = aDecoder.decodeObject(forKey: PropertyKey.themeColor) as! UIColor
        //self.insertOption = InsertOption(rawValue: aDecoder.decodeInteger(forKey: PropertyKey.insertOption))!
        self.insertOption = .extend
    }
    
    struct PropertyKey {
        static let is24Mode = "is24Mode"
        static let notifDelayTime = "notifDelayTime"
        static let themeColor = "themeColor"
        static let insertOption = "insertOption"
    }
    
   
    
}
