//
//  StreakStats.swift
//  Schedule Maker Prototype
//
//  Created by Albert Wu on 2/21/18.
//  Copyright © 2018 Old Friend. All rights reserved.
//

import UIKit

class StreakStats: NSObject, NSCoding {
    var totalDays = 0
    var dayStreak = 0
    var totalWeeks = 0
    var weekStreak = 0
    var markedDays = Set<Int>()
    var lastDayCheckedIn = 0
    
    struct PropertyKey {
        static let totalDays = "totalDays"
        static let dayStreak = "dayStreak"
        static let totalWeeks = "totalWeeks"
        static let weekStreak = "weekStreak"
        static let markedDays = "markedDays"
        static let lastDayCheckedIn = "lastDayCheckedIn"
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(totalDays, forKey: PropertyKey.totalDays)
        aCoder.encode(dayStreak, forKey: PropertyKey.dayStreak)
        aCoder.encode(totalWeeks, forKey: PropertyKey.totalWeeks)
        aCoder.encode(weekStreak, forKey: PropertyKey.weekStreak)
        aCoder.encode(markedDays, forKey: PropertyKey.markedDays)
        aCoder.encode(lastDayCheckedIn, forKey: PropertyKey.lastDayCheckedIn)
    }
    public required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        self.totalDays = aDecoder.decodeInteger(forKey: PropertyKey.totalDays)
        self.dayStreak = aDecoder.decodeInteger(forKey: PropertyKey.dayStreak)
        self.totalWeeks = aDecoder.decodeInteger(forKey: PropertyKey.totalWeeks)
        self.weekStreak = aDecoder.decodeInteger(forKey: PropertyKey.weekStreak)
        self.markedDays = aDecoder.decodeObject(forKey: PropertyKey.markedDays) as! Set<Int>
        self.lastDayCheckedIn = aDecoder.decodeInteger(forKey: PropertyKey.lastDayCheckedIn)
    }
}
