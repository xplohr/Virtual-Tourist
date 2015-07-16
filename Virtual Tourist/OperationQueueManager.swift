//
//  OperationQueueManager.swift
//  Virtual Tourist
//
//  Created by Che-Chuen Ho on 6/30/15.
//  Copyright (c) 2015 Che-Chuen Ho. All rights reserved.
//

import Foundation
import CoreData

// Reference: http://www.raywenderlich.com/76341/use-nsoperation-nsoperationqueue-swift
class OperationQueueManager {
    
    lazy var downloadsInProgress = [NSIndexPath: NSOperation]()
    lazy var downloadQueue: NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "Download Queue"
        queue.maxConcurrentOperationCount = 3
        return queue
    }()
    
    class func sharedInstance() -> OperationQueueManager {
    
        struct Singleton {
            static var instance = OperationQueueManager()
        }
        
        return Singleton.instance
    }
    
    func suspendAllOperations() {
        downloadQueue.suspended = true
    }
    
    func resumeAllOperations() {
        downloadQueue.suspended = false
    }
}