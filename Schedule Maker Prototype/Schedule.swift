//
//  Schedule.swift
//  Schedule Maker Prototype
//
//  Created by Albert Wu on 11/13/17.
//  Copyright © 2017 Old Friend. All rights reserved.
//

import UIKit


class Schedule: NSObject, NSCoding {
    var s: [Int: [ScheduleItem]]?
   
    init(s: [Int: [ScheduleItem]]) {
        self.s = s
    }
    func encode(with aCoder: NSCoder) {
     
        aCoder.encode(s, forKey: "scheduleItems")
        
        
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        self.init(s: aDecoder.decodeObject(forKey: "scheduleItems") as! [Int: [ScheduleItem]])
    }
}
