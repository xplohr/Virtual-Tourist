//
//  Location.swift
//  Virtual Tourist
//
//  Created by Che-Chuen Ho on 6/21/15.
//  Copyright (c) 2015 Che-Chuen Ho. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

class Location: NSManagedObject {

    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var createDate: NSDate
    @NSManaged var photos: [Photo]
    @NSManaged var totalPhotoPages: NSNumber
    @NSManaged var flickrInfo: FlickrInfo

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(coord: CLLocationCoordinate2D, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        latitude = coord.latitude
        longitude = coord.longitude
        createDate = NSDate()
        
        flickrInfo = FlickrInfo(pin: self, context: CoreDataStackManager.sharedInstance().managedObjectContext!)
    }
    
    func createPhotoEntries(data: [[String: AnyObject]]) {
        for photoInfo: [String: AnyObject] in data {
            let photoTitle = photoInfo[FlickrClient.JSONKeys.Photo_Title] as! String
            let photoURL = photoInfo[FlickrClient.JSONKeys.Photo_URL] as! String
            let photoID = photoInfo[FlickrClient.JSONKeys.Photo_ID] as! String
            let dictionary: [String: AnyObject] = [
                Photo.Keys.ImageID: photoID,
                Photo.Keys.Name: photoTitle,
                Photo.Keys.ImageURL: photoURL,
                Photo.Keys.Location: self
            ]
            
            let newPhoto = Photo(values: dictionary, context: CoreDataStackManager.sharedInstance().managedObjectContext!)
        }
        
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    func removeAllPhotos() {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "location == %@", self)
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStackManager.sharedInstance().managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.performFetch(nil)
        let collection = fetchedResultsController.fetchedObjects as! [Photo]
        for item in collection {
            CoreDataStackManager.sharedInstance().managedObjectContext!.deleteObject(item)
        }
        
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    func updateFlickrInfo(total: Int) {
        self.flickrInfo.downloadDate = NSDate()
        self.flickrInfo.pages = total
    }
    
    // MARK: - Flickr methods
    func getPinPhotos(completionHandler: (success: Bool, count: Int) -> Void) {
        FlickrClient.sharedInstance().searchByLatLong(self) {
            success, data, total, error in
            
            if success {
                self.totalPhotoPages = total!
                self.updateFlickrInfo(total!)
                
                if let dataDict = data {
                    if dataDict.count > 0 {
                        println("Retrieved \(total) photos!")
                        
                        self.createPhotoEntries(dataDict)
                    } else {
                        println("No photos at this location.")
                    }
                    
                    println("Retrieved the photos!")
                    completionHandler(success: true, count: dataDict.count)
                }
            } else {
                if let err = error?.userInfo {
                    println("Error getting photos for pin: \(self.latitude), \(self.longitude). \(err[VirtualTouristError.UserInfoKeys.DESCRIPTION])")
                } else {
                    println("Error getting photos for pin: \(self.latitude), \(self.longitude).")
                }
                
                completionHandler(success: false, count: 0)
            }
        }
    }
}
