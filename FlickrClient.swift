//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Che-Chuen Ho on 6/22/15.
//  Copyright (c) 2015 Che-Chuen Ho. All rights reserved.
//

import Foundation
import UIKit

class FlickrClient: NSObject {
    
    class func sharedInstance() -> FlickrClient {
    
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        
        return Singleton.sharedInstance
    }
    
    func getBBoxString(latitude: Double, longitude: Double, meters: Double) -> String {
        let distance = meters * 0.00001
        var lowerLeftLat: Double
        var upperRightLat: Double
        var lowerLeftLong: Double
        var upperRightLong: Double
        
        if latitude > 0 {
            lowerLeftLat = latitude - distance
            upperRightLat = latitude + distance
        } else {
            lowerLeftLat = latitude + distance
            upperRightLat = latitude - distance
        }
        
        if longitude > 0 {
            lowerLeftLong = longitude + distance
            upperRightLong = longitude - distance
        } else {
            lowerLeftLong = longitude - distance
            upperRightLong = longitude + distance
        }
        
        return "\(lowerLeftLong), \(lowerLeftLat), \(upperRightLong), \(upperRightLat)"
    }
    
    func searchByLatLong(pin: Location, completionHandler: (success: Bool, data: [[String: AnyObject]]?, total: Int?, error: NSError?) -> Void) {
        let arguments = [
            "method": Methods.Method_Name,
            "api_key": Constants.API_Key,
            "bbox": getBBoxString(pin.latitude.doubleValue, longitude: pin.longitude.doubleValue, meters: 10),
            "extras": Keys.Extras,
            "format": Keys.Data_Format,
            "nojsoncallback": Keys.No_JSON_Callback,
            "content_type": Keys.Photos_Only
        ]
        
        let urlString = Constants.Base_URL + UtilityMethods.escapedParameters(arguments)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        sendRequest(request) {
            success, data, total, error in
            
            completionHandler(success: success, data: data, total: total, error: error)
        }
    }
    
    func getNextPage(pin: Location, downloadedPage: Int, completionHandler: (success: Bool, data: [[String: AnyObject]]?, total: Int?, error: NSError?) -> Void) {
        
        let nextPage = downloadedPage + 1
        let arguments = [
            "method": Methods.Method_Name,
            "api_key": Constants.API_Key,
            "bbox": getBBoxString(pin.latitude.doubleValue, longitude: pin.longitude.doubleValue, meters: 10),
            "extras": Keys.Extras,
            "format": Keys.Data_Format,
            "nojsoncallback": Keys.No_JSON_Callback,
            "content_type": Keys.Photos_Only,
            "page": nextPage
        ]
        
        let urlString = Constants.Base_URL + UtilityMethods.escapedParameters(arguments as! [String : AnyObject])
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        sendRequest(request) {
            success, data, total, error in
            
            completionHandler(success: success, data: data, total: total, error: error)
        }
    }
    
    func sendRequest(request: NSURLRequest, completionHandler: (success: Bool, data: [[String: AnyObject]]?, total: Int?, error: NSError?) -> Void) {
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {
            data, response, downloadError in
            
            dispatch_async(dispatch_get_main_queue()) {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
            
            if let error = downloadError {
                println("Could not complete ther request: \(error)")
                completionHandler(success: false, data: nil, total: nil, error: error)
            } else {
                var parsingError: NSError? = nil
                let parsedResults: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: &parsingError)
                
                if let photosDictionary = parsedResults.valueForKey(JSONKeys.Photo_Dictionary) as? NSDictionary {
                    
                    let count = photosDictionary.valueForKey(JSONKeys.Photo_Pages) as? Int
                    
                    if let photoArray = photosDictionary.valueForKey(JSONKeys.Photo_Array) as? [[String: AnyObject]] {
                        
                        completionHandler(success: true, data: photoArray, total: count, error: nil)
                    } else {
                        completionHandler(success: false, data: nil, total: nil, error: NSError(domain: VirtualTouristError.DOMAIN, code: VirtualTouristError.ErrorCodes.FlickrPhotoArrayError, userInfo: [VirtualTouristError.UserInfoKeys.DESCRIPTION: "There was a problem retrieving the photos array from Flickr."]))
                    }
                } else {
                    completionHandler(success: false, data: nil, total: nil, error: NSError(domain: VirtualTouristError.DOMAIN, code: VirtualTouristError.ErrorCodes.FlickrPhotoDictionaryError, userInfo: [VirtualTouristError.UserInfoKeys.DESCRIPTION: "There was a problem retrieving the photos dictionary from Flickr."]))
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        }
        
        task.resume()
    }
    
    func downloadPhoto(urlString: String) -> UIImage? {
        if let url = NSURL(string: urlString) {
            if let data = NSData(contentsOfURL: url) {
                return UIImage(data: data)
            }
        }
        
        return nil
    }
}