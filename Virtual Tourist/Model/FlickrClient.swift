//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Ahmed Afifi on 7/28/19.
//  Copyright © 2019 Ahmed Afifi. All rights reserved.
//

import Foundation
import CoreData

class FlickrClient: NSObject {
    
    var dataController: DataController!
    
    struct Photos: Decodable {
        let photos: PhotoInfo
        let stat: String
    }
    
    struct PhotoInfo: Decodable {
        let photo: [Photo]
        let page: Int
        let pages: Int
    }
    
    struct Photo: Decodable {
        let farm: Int
        let server: String
        let id: String
        let secret: String
        let url_m: String
    }
    
    var photoResults: [Data] = []
    var searchResultsCount = 0
    var photoURLs: [URL] = []
    
    
    func clearFlickrResults() {
        photoResults = []
        photoURLs = []
    }
    
    func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        var components = URLComponents()
        components.scheme = FlickrClient.Constants.Flickr.APIScheme
        components.host = FlickrClient.Constants.Flickr.APIHost
        components.path = FlickrClient.Constants.Flickr.APIPath
        
        return components.url!
    }
    
    func downloadPhotosForLocation1(lat: Double, lon: Double, _ completionHandlerForDownload: @escaping (_ result: Bool, _ urls: [URL]?) -> Void) {
        let urlString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=ad57c918d7705a17a075a02858b94f59&lat=\(lat)&lon=\(lon)&radius=1&per_page=21&extras=url_m&format=json&nojsoncallback=1"
        let url = URL(string: urlString)
        let session = URLSession.shared
        let request = URLRequest(url: url!)
        let task = session.dataTask(with: request) { (data, response, error) in
            guard (error == nil) else{
                print("error downloading photos: \(error!)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("request returned status code other than 2XX")
                return
            }
            
            guard let data = data else {
                print("could not download data")
                return
            }
            
            guard let photosInfo = try? JSONDecoder().decode(Photos.self, from: data) else {
                print("error in decoding process")
                return
            }
            
            self.searchResultsCount = photosInfo.photos.photo.count
            print("search results count: \(self.searchResultsCount)")
            
            let totalPages = photosInfo.photos.pages
            let pageLimit = min(totalPages, 100)
            let randomPageNumber = Int(arc4random_uniform(UInt32(pageLimit))) + 1
            print("random page number = \(randomPageNumber)")
            
            self.searchForRandomPhotos(urlString: urlString, pageNumber: randomPageNumber, completionHandlerfForRandomPhotoSearch: { (success, urlsToDownload) in
                guard let urlsToDownload = urlsToDownload else {
                    print("no urls returned from random search")
                    return
                }
                
                if (success == true) {
                    self.photoURLs.append(contentsOf: urlsToDownload)
                    print("photoURLs count: \(self.photoURLs.count)")
                    completionHandlerForDownload(success, urlsToDownload)
                }
            })
        }
        task.resume()
    }
    
    
    func searchForRandomPhotos(urlString: String, pageNumber: Int, completionHandlerfForRandomPhotoSearch: @escaping (_ result: Bool, _ urls: [URL]?) -> Void) {
    
        let urlStringWithPageNumber = urlString.appending("&page=\(pageNumber)")
        let url = URL(string: urlStringWithPageNumber)
        let session = URLSession.shared
        let request = URLRequest(url: url!)
        let task = session.dataTask(with: request) { (data, response, error) in
            guard (error == nil) else{
                print("error downloading photos: \(error!)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("request returned status code other than 2XX")
                return
            }
            
            guard let data = data else {
                print("could not download data")
                return
            }
            
            guard let randomPhotosInfo = try? JSONDecoder().decode(Photos.self, from: data) else {
                print("error in decoding process")
                return
            }
            
            var urlArray = [URL]()
            for photo in randomPhotosInfo.photos.photo {
                if let photoURL = URL(string: photo.url_m) {
                    urlArray.append(photoURL)
                }
            }
            completionHandlerfForRandomPhotoSearch(true, urlArray)
        }
        task.resume()
    }
    
    
    func makeImageDataFrom(flickrURL: URL) -> Data? {
        return try? Data(contentsOf: flickrURL)
    }
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static let sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
}

