//
//  FlickerConstants.swift
//  Virtual Tourist
//
//  Created by Ahmed Afifi on 7/28/19.
//  Copyright © 2019 Ahmed Afifi. All rights reserved.
//

extension FlickrClient {
    
    struct Constants {
        
        // MARK: FLICKR
        struct Flickr {
            static let APIScheme = "https"
            static let APIHost = "api.flickr.com"
            static let APIPath = "/services/rest"
        }
        
        // MARK: Flickr Parameter Keys
        struct FlickrParameterKeys {
            static let Method = "method"
            static let APIKey = "api_key"
            static let Latitude = "lat"
            static let Longitude = "lon"
            static let Radius = "radius"
            static let ResultsPerPage = "per_page"
            static let format = "format"
            static let NoJSONCallback = "nojsoncallback"
        }
        
        // MARK: Flickr Parameter Values
        struct FlickrParameterValues {
            static let SearchMethod = "flickr.photos.search"
            static let APIKey = "ad57c918d7705a17a075a02858b94f59"
            static let ResponseRadius = "1" // 1 mile radius
            static let ResponseResultsPerPage = "100"
            static let ResponseFormat = "json"
            static let DisableJSONCallback = "1" // 1 means "yes"
            
        }
    }
    
}
