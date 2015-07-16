//
//  VirtualTouristError.swift
//  Virtual Tourist
//
//  Created by Che-Chuen Ho on 6/24/15.
//  Copyright (c) 2015 Che-Chuen Ho. All rights reserved.
//

import Foundation

class VirtualTouristError: NSObject {
    
    struct UserInfoKeys {
    
        static let DESCRIPTION = "description"
    }
    
    struct ErrorCodes {
    
        static let FlickrPhotoDictionaryError: Int = 100
        static let FlickrPhotoArrayError: Int = 200
    }
    
    static let DOMAIN = "Virtual_Tourist"
}