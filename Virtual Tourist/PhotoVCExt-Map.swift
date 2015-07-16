//
//  PhotoVCExt-Map.swift
//  Virtual Tourist
//
//  Created by Che-Chuen Ho on 6/29/15.
//  Copyright (c) 2015 Che-Chuen Ho. All rights reserved.
//

import MapKit

extension PhotosViewController: MKMapViewDelegate {
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, CoreLocationStackManager.Defaults.regionRadius * 2.0, CoreLocationStackManager.Defaults.regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.userInteractionEnabled = false
        
        let annotation = LocationPin(location: pin!)
        
        mapView.addAnnotation(annotation)
    }
    
    // MARK: - MKMapViewDelegate
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if let annotation = annotation as? LocationPin {
            let identifier = "pin"
            var view: MKPinAnnotationView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = false
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIView
            }
            
            return view
        }
        
        return nil
    }
}
