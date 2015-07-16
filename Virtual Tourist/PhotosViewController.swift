//
//  PhotosViewController.swift
//  Virtual Tourist
//
//  Created by Che-Chuen Ho on 6/28/15.
//  Copyright (c) 2015 Che-Chuen Ho. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotosViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photoCollection: UICollectionView!
    @IBOutlet weak var noPhotosLabel: UILabel!
    
    var pin: Location?
    var delegate: LocationsViewController?
    var downloadedPages = 0
    var totalPages = 1
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "location == %@", self.pin!)
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStackManager.sharedInstance().managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        if pin != nil {
            centerMapOnLocation(CLLocation(latitude: pin!.latitude.doubleValue, longitude: pin!.longitude.doubleValue))
            
            if pin!.photos.count == 0 {
                photoCollection.hidden = true
                noPhotosLabel.hidden = false
            } else {
                photoCollection.hidden = false
                noPhotosLabel.hidden = true
            }
        }
        
        fetchedResultsController.performFetch(nil)
        fetchedResultsController.delegate = self
    }
    
    @IBAction func loadNewCollection(sender: AnyObject) {
        getNextCollection()
    }
    
}
