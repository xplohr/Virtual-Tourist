//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Che-Chuen Ho on 6/22/15.
//  Copyright (c) 2015 Che-Chuen Ho. All rights reserved.
//

import UIKit
import CoreData

class Photo: NSManagedObject {
    
    struct Keys {
    
        static let ImageID = "ID"
        static let Name = "name"
        static let ImageURL = "url"
        static let Location = "pin"
    }
    
    struct PhotoRecordState {
        
        static let New = 0
        static let Downloaded = 1
        static let Failed = 2
    }

    @NSManaged var imageURL: String
    @NSManaged var title: String
    @NSManaged var id: String
    @NSManaged var location: Location
    @NSManaged var state: NSNumber

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(values: [String: AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.id = values[Keys.ImageID] as! String
        self.title = values[Keys.Name] as! String
        self.imageURL = values[Keys.ImageURL] as! String
        self.location = values[Keys.Location] as! Location
        self.state = PhotoRecordState.New
    }
    
    func getStoredImage() -> UIImage? {
        return DocumentsDirManager.sharedInstance().getImageFromPath(DocumentsDirManager.sharedInstance().getImagePath(self.id))
    }
    
    override func prepareForDeletion() {
        DocumentsDirManager.sharedInstance().removeDocument("\(id).png")
    }
}
