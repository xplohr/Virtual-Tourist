//
//  CoreLocationStackManager.swift
//  Virtual Tourist
//
//  Created by Che-Chuen Ho on 6/20/15.
//  Copyright (c) 2015 Che-Chuen Ho. All rights reserved.
//

import CoreLocation
import UIKit

class CoreLocationStackManager {
    
    struct Defaults {
        static let regionRadius: CLLocationDistance = 1000
        static let accuracy = kCLLocationAccuracyBest
        static let moveThreshold: CLLocationDistance = 10.0 // meters
    }
    
    var locationManager = CLLocationManager()
    
    class func sharedInstance() -> CoreLocationStackManager {
    
        struct Singleton {
            static var sharedInstance = CoreLocationStackManager()
        }
        
        return Singleton.sharedInstance
    }
    
    func requestLocationAuthorization(delegate: CLLocationManagerDelegate) {
        locationManager.delegate = delegate
        locationManager.requestWhenInUseAuthorization()
    }
    
    func checkLocationServices() -> Bool {
        if !CLLocationManager.locationServicesEnabled() {
            let alert = UIAlertView(title: "Location Services Error", message: "Please go to the Settings app and enable Location Services for this app.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            return false
        } else {
            return true
        }
    }
    
    // MARK: - User location methods
    func startUpdatingLocation(delegate: CLLocationManagerDelegate) {
        if checkLocationServices() {
            locationManager.delegate = delegate
            locationManager.desiredAccuracy = Defaults.accuracy
            locationManager.distanceFilter = Defaults.moveThreshold
            
            locationManager.startUpdatingLocation()
        }
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func startSignificantChangeUpdates(delegate: CLLocationManagerDelegate) {
        if checkLocationServices() {
            locationManager.delegate = delegate
            locationManager.startMonitoringSignificantLocationChanges()
        }
    }
    
    func stopSignificantChangeUpdates() {
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
}