//
//  LocationsVCExt.swift
//  Virtual Tourist
//
//  Created by Che-Chuen Ho on 6/20/15.
//  Copyright (c) 2015 Che-Chuen Ho. All rights reserved.
//

import CoreLocation
import UIKit

extension LocationsViewController: CLLocationManagerDelegate {
    
    // MARK: - CLLocation Manager methods
    func checkLocationAuthorization() {
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse {
            showCurrentLocation()
        } else {
            CoreLocationStackManager.sharedInstance().requestLocationAuthorization(self)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            showCurrentLocation()
        }
    }
}