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
    
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(taskName, forKey: PropertyKey.taskName)
        aCoder.encode(duration, forKey: PropertyKey.duration)
        aCoder.encode(startTime, forKey: PropertyKey.startTime)
        aCoder.encode(locked, forKey: PropertyKey.locked)
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
    
    public struct PropertyKey {
        static let taskName = "taskName"
        static let duration = "duration"
        static let startTime = "startTime"
        static let locked = "locked"
    }
    public required convenience init?(coder aDecoder: NSCoder) {
        guard let taskName = aDecoder.decodeObject(forKey: PropertyKey.taskName) as? String else {
            os_log("Unable to decode taskName for ScheduleItem object", log: .default, type: .debug)
            return nil
        }
        
        let duration = aDecoder.decodeInteger(forKey: PropertyKey.duration)
        
        let startTime = aDecoder.decodeObject(forKey: PropertyKey.startTime) as! Int?
        let locked = aDecoder.decodeBool(forKey: PropertyKey.locked)
        self.init(name: taskName, duration:duration)
        self.startTime = startTime
        self.locked = locked
    }
}
