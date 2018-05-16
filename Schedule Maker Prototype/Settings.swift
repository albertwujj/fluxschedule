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
    var is5MinIncrement: Bool = false
    var notifDelayTime = 10
    //var themeColor:UIColor = UIColor(displayP3Red: 10/255, green: 0/255, blue: 220/255, alpha: 1.0) //darkblue
    //var themeColor:UIColor = UIColor(displayP3Red: 0/255, green: 178/255, blue: 176/255, alpha: 1.0) //teal
    //var themeColor:UIColor = UIColor(displayP3Red: 1/255, green: 160/255, blue: 163/255, alpha: 1.0) //dark teal
    //var themeColor:UIColor = UIColor(displayP3Red: 216/255, green: 13/255, blue: 13/255, alpha: 1.0)
    //var themeColor:UIColor = UIColor(displayP3Red: 206/255, green: 208/255, blue: 238/255, alpha: 1.0) //whiteblue
    var themeColor: UIColor = .blue
    
    var insertOption: InsertOption = .split
    var defaultStartTime: Int = 7 * 3600
    var defaultName: String = "New Item"
    var defaultDuration = 30 * 60
    var notificationsOn = true
    var fluxPlus = true
    var subs = true
    func encode(with aCoder: NSCoder) {
        aCoder.encode(is24Mode, forKey: PropertyKey.is24Mode)
        aCoder.encode(notifDelayTime, forKey: PropertyKey.notifDelayTime)
        aCoder.encode(themeColor, forKey: PropertyKey.themeColor)
        aCoder.encode(insertOption.rawValue, forKey: PropertyKey.insertOption)
        aCoder.encode(defaultStartTime as Any, forKey: PropertyKey.defaultStartTime)
        aCoder.encode(defaultDuration as Any, forKey: PropertyKey.defaultDuration)
        aCoder.encode(defaultName, forKey: PropertyKey.defaultName)
        aCoder.encode(is5MinIncrement, forKey: PropertyKey.is5MinIncrement)
        aCoder.encode(notificationsOn as Any, forKey: PropertyKey.notificationsOn)
        aCoder.encode(fluxPlus, forKey: PropertyKey.fluxPlus)
        aCoder.encode(subs, forKey: PropertyKey.subs)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        self.is24Mode = aDecoder.decodeBool(forKey: PropertyKey.is24Mode)
        self.is5MinIncrement = aDecoder.decodeBool(forKey: PropertyKey.is5MinIncrement)
        self.notifDelayTime = aDecoder.decodeInteger(forKey: PropertyKey.notifDelayTime)
        self.defaultStartTime = (aDecoder.decodeObject(forKey: PropertyKey.defaultStartTime) ?? 7 * 3600) as! Int
        self.defaultDuration = (aDecoder.decodeObject(forKey: PropertyKey.defaultDuration) ?? 30 * 60) as! Int
        //self.themeColor = aDecoder.decodeObject(forKey: PropertyKey.themeColor) as! UIColor
        self.notificationsOn = (aDecoder.decodeObject(forKey: PropertyKey.notificationsOn) ?? true) as! Bool
        self.fluxPlus = aDecoder.decodeBool(forKey: PropertyKey.fluxPlus) 
        self.subs = aDecoder.decodeBool(forKey: PropertyKey.subs) 
        //self.insertOption = InsertOption(rawValue: aDecoder.decodeInteger(forKey: PropertyKey.insertOption))!
        self.insertOption = .split

        //self.defaultStartTime = aDecoder.decodeInteger(forKey: PropertyKey.defaultStartTime)
        //self.defaultName =
    }
    
    struct PropertyKey {
        static let is24Mode = "is24Mode"
        static let notifDelayTime = "notifDelayTime"
        static let themeColor = "themeColor"
        static let insertOption = "insertOption"
        static let defaultStartTime = "defaultStartTime"
        static let defaultDuration = "defaultDuration"
        static let defaultName = "defaultName"
        static let is5MinIncrement = "is5MinIncrement"
        static let notificationsOn = "notificationsOn"
        static let fluxPlus = "fluxPlus"
        static let subs = "subs"
    }
    
   
    
}
