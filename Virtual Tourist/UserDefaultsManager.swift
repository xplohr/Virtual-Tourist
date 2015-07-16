//
//  UserDefaultsManager.swift
//  Virtual Tourist
//
//  Created by Che-Chuen Ho on 6/20/15.
//  Copyright (c) 2015 Che-Chuen Ho. All rights reserved.
//

import Foundation
import CoreLocation

class UserDefaultsManager {
    let defaults = NSUserDefaults.standardUserDefaults()
    
    struct Keys {
        static let LastLatitude = "lastMapLatitude"
        static let LastLongitude = "lastMapLongitude"
    }
    
    class func sharedInstance() -> UserDefaultsManager {
        struct Singleton {
            static var sharedInstance = UserDefaultsManager()
        }
        
        return Singleton.sharedInstance
    }
    
    func getLastLocation() -> CLLocation? {
        let lat = defaults.doubleForKey(Keys.LastLatitude)
        let long = defaults.doubleForKey(Keys.LastLongitude)
        
        if lat != 0.0 && long != 0.0 {
            return CLLocation(latitude: lat, longitude: long)
        } else {
            return nil
        }
    }
    
    func setLastLocation(location: CLLocation) {
        defaults.setDouble(location.coordinate.latitude, forKey: Keys.LastLatitude)
        defaults.setDouble(location.coordinate.longitude, forKey: Keys.LastLongitude)
    }
}