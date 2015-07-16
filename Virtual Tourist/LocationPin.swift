//
//  LocationPin.swift
//  Virtual Tourist
//
//  Created by Che-Chuen Ho on 6/21/15.
//  Copyright (c) 2015 Che-Chuen Ho. All rights reserved.
//

import Foundation
import MapKit

class LocationPin: NSObject, MKAnnotation {
    
    static let reuseID = "pin"
    
    var location: Location
    var name: String
    var coordinate: CLLocationCoordinate2D
    
    init(location: Location) {
        self.location = location
        self.name = "Loading photos..."
        self.coordinate = CLLocationCoordinate2D(latitude: self.location.latitude.doubleValue, longitude: self.location.longitude.doubleValue)
        
        super.init()
    }
    
    var title: String {
        if location.photos.isEmpty {
            return "Tap to load photos"
        } else {
            return "\(location.photos.count) photos"
        }
    }
}