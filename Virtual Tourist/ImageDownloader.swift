//
//  ImageDownloader.swift
//  Virtual Tourist
//
//  Created by Che-Chuen Ho on 6/30/15.
//  Copyright (c) 2015 Che-Chuen Ho. All rights reserved.
//

import Foundation
import UIKit

class ImageDownloader: NSOperation {
    
    let photoRecord: Photo
    
    init(photoRecord: Photo) {
        self.photoRecord = photoRecord
    }
    
    override func main() {
        
        if self.cancelled {
            return
        }
        
        let imageData = NSData(contentsOfURL: NSURL(string: photoRecord.imageURL)!)
        
        if self.cancelled {
            return
        }
        
        if imageData?.length > 0 {
            DocumentsDirManager.sharedInstance().writeImage(UIImage(data: imageData!)!, title: photoRecord.id)
            photoRecord.state = Photo.PhotoRecordState.Downloaded
            CoreDataStackManager.sharedInstance().saveContext()
        } else {
            photoRecord.state = Photo.PhotoRecordState.Failed
        }
    }
}