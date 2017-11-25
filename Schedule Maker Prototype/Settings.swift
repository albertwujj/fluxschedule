//
//  Settings.swift
//  Schedule Maker Prototype
//
//  Created by Albert Wu on 11/24/17.
//  Copyright © 2017 Old Friend. All rights reserved.
//

import UIKit

class Settings: NSObject, NSCoding {
    var is24Mode: Bool = false

    func encode(with aCoder: NSCoder) {
        aCoder.encode(is24Mode, forKey: PropertyKey.is24Mode)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        self.is24Mode = aDecoder.decodeBool(forKey: PropertyKey.is24Mode)
    }
    struct PropertyKey {
        static let is24Mode = "is24Mode"
    }
    
   
    
}
