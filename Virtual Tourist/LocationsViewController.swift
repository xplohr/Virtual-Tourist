//
//  LocationsViewController.swift
//  Virtual Tourist
//
//  Created by Che-Chuen Ho on 6/12/15.
//  Copyright (c) 2015 Che-Chuen Ho. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class LocationsViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Location")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createDate", ascending: false)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStackManager.sharedInstance().managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchedResultsController.performFetch(nil)
        fetchedResultsController.delegate = self
        
        if (fetchedResultsController.fetchedObjects != nil) {
            showPins()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setStarterLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showPhotosAlbum(pin: LocationPin) {
        let controller = storyboard!.instantiateViewControllerWithIdentifier("PhotosViewController") as! PhotosViewController
        controller.pin = pin.location
        controller.totalPages = pin.location.totalPhotoPages.integerValue
        controller.downloadedPages = 1
        
        self.navigationController!.pushViewController(controller, animated: true)
    }

}

