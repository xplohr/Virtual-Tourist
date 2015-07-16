//
//  LocationVCExt-Map.swift
//  Virtual Tourist
//
//  Created by Che-Chuen Ho on 6/21/15.
//  Copyright (c) 2015 Che-Chuen Ho. All rights reserved.
//

import MapKit

extension LocationsViewController: CLLocationManagerDelegate, MKMapViewDelegate {
    
    func setStarterLocation() {
        let location = UserDefaultsManager.sharedInstance().getLastLocation()
        
        if location != nil {
            centerMapOnLocation(location!)
        } else {
            checkLocationAuthorization()
        }
    }
    
    // Inspired by the MapKit tutorial on http://www.raywenderlich.com/90971/introduction-mapkit-swift-tutorial
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, CoreLocationStackManager.Defaults.regionRadius * 2.0, CoreLocationStackManager.Defaults.regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func showCurrentLocation() {
        mapView.showsUserLocation = true
        CoreLocationStackManager.sharedInstance().startUpdatingLocation(self)
    }
    
    @IBAction func dropPin(recognizer: UILongPressGestureRecognizer) {
        // Reference: http://stackoverflow.com/questions/3319591/uilongpressgesturerecognizer-gets-called-twice-when-pressing-down
        if recognizer.state == .Ended {
            // Reference: https://freshmob.com.au/mapkit-tap-and-hold-to-drop-a-pin-on-the-map/
            let point: CGPoint = recognizer.locationInView(mapView)
            let locCoord = mapView.convertPoint(point, toCoordinateFromView: mapView)
            let location = Location(coord: locCoord, context: CoreDataStackManager.sharedInstance().managedObjectContext!)
            let pin = LocationPin(location: location)
            let pinView = MKAnnotationView(annotation: pin, reuseIdentifier: LocationPin.reuseID)
            
            mapView.addAnnotation(pin)
            CoreDataStackManager.sharedInstance().saveContext()
            UserDefaultsManager.sharedInstance().setLastLocation(CLLocation(latitude: locCoord.latitude, longitude: locCoord.longitude))
        }
    }
    
    func showPins() {
        for savedLocation in fetchedResultsController.fetchedObjects! {
            let location = savedLocation as! Location
            let pin = LocationPin(location: location)
            mapView.addAnnotation(pin)
        }
    }
    
    // MARK: - MKMapViewDelegate
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if let annotation = annotation as? LocationPin {
            var view: MKPinAnnotationView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(LocationPin.reuseID) as? MKPinAnnotationView {
                
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: LocationPin.reuseID)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.draggable = true
                view.animatesDrop = true
                view.enabled = true
                
                let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                spinner.hidesWhenStopped = true
                spinner.startAnimating()
                view.rightCalloutAccessoryView = spinner
            }
                
            loadPhotosForPinView(annotation, pinView: view)
            
            return view
        }
        
        return nil
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        
        if control.isKindOfClass(UIButton) {
            let pin = view.annotation as! LocationPin
            
            if pin.location.photos.isEmpty {
                
                pin.location.getPinPhotos() {
                    success, count in
                    
                    if count == 0 {
                        UtilityMethods.showErrorAlert("Flickr Photos", message: "No photos found for this location!")
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        mapView.deselectAnnotation(view.annotation, animated: true)
                        self.showPhotosAlbum(pin)
                    }
                }
            } else {
                showPhotosAlbum(pin)
            }
        }
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        
        if newState == .Ending {
            let newPin = view.annotation as! LocationPin
            newPin.location.latitude = newPin.coordinate.latitude
            newPin.location.longitude = newPin.coordinate.longitude
            newPin.location.removeAllPhotos()
            mapView.reloadInputViews()
            CoreDataStackManager.sharedInstance().saveContext()
            UserDefaultsManager.sharedInstance().setLastLocation(CLLocation(latitude: newPin.location.latitude.doubleValue, longitude: newPin.location.longitude.doubleValue))
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        let currentLocation = locations.last as! CLLocation
        let eventDate = currentLocation.timestamp
        let howRecent = eventDate.timeIntervalSinceNow
        
        if abs(howRecent) < 15.0 {
            centerMapOnLocation(currentLocation)
            CoreLocationStackManager.sharedInstance().stopUpdatingLocation()
        }
    }
    
    // MARK: - Utility Methods
    func loadPhotosForPinView(pin: LocationPin, pinView: MKAnnotationView) {
        if pin.location.photos.isEmpty {
            pin.location.getPinPhotos() {
                success, count in
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.mapView.reloadInputViews()
                    let spinner = pinView.rightCalloutAccessoryView as! UIActivityIndicatorView
                    spinner.stopAnimating()
                    
                    pinView.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIView
                }
            }
        } else {
            dispatch_async(dispatch_get_main_queue()) {
                let spinner = pinView.rightCalloutAccessoryView as! UIActivityIndicatorView
                spinner.stopAnimating()
                
                pinView.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIView
            }
        }
    }
}