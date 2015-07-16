//
//  PhotoVCExt.swift
//  Virtual Tourist
//
//  Created by Che-Chuen Ho on 6/29/15.
//  Copyright (c) 2015 Che-Chuen Ho. All rights reserved.
//

import UIKit

extension PhotosViewController {
    
    // MARK: - Background download photos
    // Reference: http://www.raywenderlich.com/76341/use-nsoperation-nsoperationqueue-swift
    func downloadImageInBackground(photoInfo: Photo, indexPath: NSIndexPath) {
        
        if let downloadOperation = OperationQueueManager.sharedInstance().downloadsInProgress[indexPath] {
            
            return
        }
        
        let downloader = ImageDownloader(photoRecord: photoInfo)
        downloader.completionBlock = {
            if downloader.cancelled {
                return
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                OperationQueueManager.sharedInstance().downloadsInProgress.removeValueForKey(indexPath)
               self.photoCollection.reloadItemsAtIndexPaths([indexPath])
            }
        }
        
        OperationQueueManager.sharedInstance().downloadsInProgress[indexPath] = downloader
        OperationQueueManager.sharedInstance().downloadQueue.addOperation(downloader)
    }
    
    func getNextCollection() {
        removeAllPhotos()
        getMorePhotos()
    }
    
    func removeAllPhotos() {
        
        pin?.removeAllPhotos()
        fetchedResultsController.performFetch(nil)
        photoCollection.reloadData()
    }
    
    func getMorePhotos() {
        if downloadedPages < totalPages {
            FlickrClient.sharedInstance().getNextPage(pin!, downloadedPage: downloadedPages) {
                success, data, total, error in
                
                if success {
                    if let dataDict = data {
                        if dataDict.count > 0 {
                            self.pin!.createPhotoEntries(dataDict)
                            dispatch_async(dispatch_get_main_queue()) {
                                self.fetchedResultsController.performFetch(nil)
                                self.photoCollection.reloadData()
                            }
                        } else {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.photoCollection.hidden = true
                                self.noPhotosLabel.hidden = false
                            }
                        }
                    }
                    
                    self.totalPages = total!
                    self.downloadedPages += 1
                    if self.downloadedPages >= self.totalPages {
                        self.downloadedPages = 0
                    }
                    
                    // Migrate to new FlickrInfo model
                    self.pin?.flickrInfo.incrementPage(total!)
                } else {
                    if let err = error?.userInfo {
                        println("Error getting photos for pin: \(self.pin!.latitude), \(self.pin!.longitude). \(err[VirtualTouristError.UserInfoKeys.DESCRIPTION])")
                    } else {
                        println("Error getting photos for pin: \(self.pin!.latitude), \(self.pin!.longitude).")
                    }
                }
            }
        } else {
            UtilityMethods.showErrorAlert("Flickr Photos", message: "No more photos to download.")
        }
    }
    
}
