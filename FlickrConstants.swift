//
//  FlickrConstants.swift
//  Virtual Tourist
//
//  Created by Che-Chuen Ho on 6/24/15.
//  Copyright (c) 2015 Che-Chuen Ho. All rights reserved.
//

extension FlickrClient {
    
    struct Constants {
        static let Base_URL = "https://api.flickr.com/services/rest/"
        static let API_Key = "16a95364fb4f3cddfc67a38d9a333cec"
    }
    
    struct Methods {
        static let Method_Name = "flickr.photos.search"
    }
    
    struct Keys {
        static let Extras = "url_m"
        static let Data_Format = "json"
        static let No_JSON_Callback = "1"
        static let Photos_Only = "1"
    }
    
    struct JSONKeys {
        static let Photo_Dictionary = "photos"
        static let Photo_Array = "photo"
        static let Photo_Title = "title"
        static let Photo_URL = "url_m"
        static let Photo_Count = "total"
        static let Photo_ID = "id"
        static let Photo_Pages = "pages"
    }
}