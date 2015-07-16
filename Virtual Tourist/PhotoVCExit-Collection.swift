//
//  PhotoVCExit-Collection.swift
//  Virtual Tourist
//
//  Created by Che-Chuen Ho on 6/28/15.
//  Copyright (c) 2015 Che-Chuen Ho. All rights reserved.
//

import UIKit

extension PhotosViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - UICollectionView Data Source
    // Reference: http://www.raywenderlich.com/78550/beginning-ios-collection-views-swift-part-1
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if !fetchedResultsController.fetchedObjects!.isEmpty {
            return fetchedResultsController.fetchedObjects!.count
        }
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! PhotoCell
        
        cell.backgroundColor = UIColor.grayColor()
        
        let photoInfo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        let image = photoInfo.getStoredImage()
        
        if let storedImage = photoInfo.getStoredImage() {
            
            cell.setPhoto(storedImage, hidden: false)
            cell.setLoadingIndicator(false)
        } else {
            
            cell.setPhoto(nil, hidden: true)
            cell.setLoadingIndicator(true)
            
            if (!collectionView.dragging && !collectionView.decelerating) {
                downloadImageInBackground(photoInfo, indexPath: indexPath)
            }
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let photoInfo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        CoreDataStackManager.sharedInstance().managedObjectContext?.deleteObject(photoInfo)
        CoreDataStackManager.sharedInstance().saveContext()
        fetchedResultsController.performFetch(nil)
        collectionView.reloadData()
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        OperationQueueManager.sharedInstance().suspendAllOperations()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if !decelerate {
            loadImagesForOnscreenCells()
            OperationQueueManager.sharedInstance().resumeAllOperations()
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        loadImagesForOnscreenCells()
        OperationQueueManager.sharedInstance().resumeAllOperations()
    }
    
    // MARK: - Utility methods
    
    func loadImagesForOnscreenCells() {
        
        let pathsArray = photoCollection.indexPathsForVisibleItems()
        
        if !pathsArray.isEmpty {
            var allPendingOperations = Set(OperationQueueManager.sharedInstance().downloadsInProgress.keys.array)
            var toBeCancelled = allPendingOperations
            let visiblePaths = Set(pathsArray as! [NSIndexPath])
            toBeCancelled.subtractInPlace(visiblePaths)
            
            var toBeStarted = visiblePaths
            toBeStarted.subtractInPlace(allPendingOperations)
            
            for indexPath in toBeCancelled {
                if let pendingDownload = OperationQueueManager.sharedInstance().downloadsInProgress[indexPath] {
                    pendingDownload.cancel()
                }
                
                OperationQueueManager.sharedInstance().downloadsInProgress.removeValueForKey(indexPath)
            }
            
            for indexPath in toBeStarted {
                let indexPath = indexPath as NSIndexPath
                let recordToProcess = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
                downloadImageInBackground(recordToProcess, indexPath: indexPath)
            }
        }
    }
}
