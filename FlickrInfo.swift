//
//  FlickrInfo.swift
//  Virtual Tourist
//
//  Created by Che-Chuen Ho on 7/6/15.
//  Copyright (c) 2015 Che-Chuen Ho. All rights reserved.
//

import Foundation
import CoreData

class FlickrInfo: NSManagedObject {

    @NSManaged var downloadDate: NSDate
    @NSManaged var pages: NSNumber
    @NSManaged var lastDownloadedPage: NSNumber
    @NSManaged var totalPhotos: NSNumber
    @NSManaged var location: Location
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(pin: Location, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("FlickrInfo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.location = pin
        self.lastDownloadedPage = 0
    }
    
    func incrementPage(total: Int) {
        pages = total
        lastDownloadedPage = lastDownloadedPage.integerValue + 1
        if lastDownloadedPage.integerValue >= pages.integerValue {
            lastDownloadedPage = 0
        }
    }

}
