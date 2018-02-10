//
//  ScheduleItem.swift
//  ScheduleMakerClasses
//
//  Created by Albert Wu on 12/16/17.
//  Copyright © 2017 Old Friend. All rights reserved.
//

import Foundation


import os.log
import UIKit

public class ScheduleItem: NSObject, NSCoding {
    
    
    public var taskName: String = ""
    //duration represented in seconds
    public var duration: Int = 0
    //startTime represented in seconds since midnight
    public var startTime: Int?
    public var locked:Bool = false
    public var recurDays:Set<Int>? = Set<Int>()
    public var oldRow: Int?

    //duration represented in seconds
    public var initialDuration: Int?
    //startTime represented in seconds since midnight
    public var initialStartTime: Int?
    public var previousStartTime: Int?


    public var inColor:Bool = false

    public struct PropertyKey {
        static let taskName = "taskName"
        static let duration = "duration"
        static let startTime = "startTime"
        static let locked = "locked"
        static let recurDays = "recurDays"
        static let row = "row"
        static let pseudoLocked = "pseudoLocked"
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(taskName, forKey: PropertyKey.taskName)
        aCoder.encode(duration, forKey: PropertyKey.duration)
        aCoder.encode(startTime, forKey: PropertyKey.startTime)
        aCoder.encode(locked, forKey: PropertyKey.locked)
        aCoder.encode(recurDays, forKey: PropertyKey.recurDays)
        aCoder.encode(oldRow, forKey: PropertyKey.row)
    }
    
    
    public init(name: String, duration: Int) {
        self.taskName = name
        self.duration = duration
    }
    public convenience init(name: String, duration: Int, locked: Bool) {
        self.init(name: name, duration: duration)
        self.locked = locked
    }
    public convenience init(name: String, duration: Int, startTime: Int) {
        self.init(name: name, duration: duration)
        self.startTime = startTime
    }
    
   
    public required convenience init?(coder aDecoder: NSCoder) {
        guard let taskName = aDecoder.decodeObject(forKey: PropertyKey.taskName) as? String else {
            os_log("Unable to decode taskName for ScheduleItem object", log: .default, type: .debug)
            return nil
        }
        
        let duration = aDecoder.decodeInteger(forKey: PropertyKey.duration)
        let row = aDecoder.decodeObject(forKey: PropertyKey.row) as! Int?
        let startTime = aDecoder.decodeObject(forKey: PropertyKey.startTime) as! Int?
        let locked = aDecoder.decodeBool(forKey: PropertyKey.locked)
        let recurDays = aDecoder.decodeObject(forKey: PropertyKey.recurDays) as! Set<Int>?
        self.init(name: taskName, duration:duration)
        self.startTime = startTime
        self.locked = locked
        self.recurDays = recurDays
        self.oldRow = row
    }
    public func deepCopy() -> ScheduleItem {
        let deepCopy = ScheduleItem(name: self.taskName, duration: self.duration, locked: self.locked)
        deepCopy.startTime = self.startTime
        deepCopy.recurDays = self.recurDays
        deepCopy.initialStartTime = self.initialStartTime
        return deepCopy
    }
}
