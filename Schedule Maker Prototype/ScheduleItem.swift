//
//  ScheduleItem.swift
//  Schedule Maker Prototype
//
//  Created by Albert Wu on 11/7/17.
//  Copyright © 2017 Old Friend. All rights reserved.
//

import os.log
import UIKit

class ScheduleItem: NSObject, NSCoding {
    
    
    var taskName: String = ""
    //duration represented in seconds
    var duration: Int = 0
    //startTime represented in seconds since midnight
    var startTime: Int?
    var locked:Bool = false
    
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(taskName, forKey: PropertyKey.taskName)
        aCoder.encode(duration, forKey: PropertyKey.duration)
        aCoder.encode(startTime, forKey: PropertyKey.startTime)
        aCoder.encode(locked, forKey: PropertyKey.locked)
    }
    
   
    init(name: String, duration: Int) {
        self.taskName = name
        self.duration = duration
    }
    convenience init(name: String, duration: Int, startTime: Int) {
        self.init(name: name, duration: duration)
        self.startTime = startTime
    }
    struct PropertyKey {
        static let taskName = "taskName"
        static let duration = "duration"
        static let startTime = "startTime"
        static let locked = "locked"
    }
    required convenience init?(coder aDecoder: NSCoder) {
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
