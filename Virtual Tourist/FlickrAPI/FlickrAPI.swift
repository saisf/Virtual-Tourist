//
//  APIClient.swift
//  Virtual Tourist
//
//  Created by Sai Leung on 6/11/18.
//  Copyright © 2018 Sai Leung. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

struct APIClient {
    
    var manager: SDWebImageManager = SDWebImageManager.shared()
    
    func displayImageFromFlickr(completion: @escaping(_ success: Bool,_ image: [CodablePhoto]?,_ error: Error? ) -> Void) {
        
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.BoundingBox: bboxString(),
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.PerPage:
                Constants.FlickrParameterValues.PerPage,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
        ]
        // create session and request
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(methodParameters as [String : AnyObject]))
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print("There was an error with your request: \(error)")
                completion(false, nil, error)
                return
            }
            guard let data = data else {
                print("Error: \(error!)")
                completion(false, nil, error)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                return
            }
            
            if let jsonResults = try? JSONDecoder().decode(Stat.self, from: data) {
                
                guard let totalPages = jsonResults.photos.pages else {return}
                
                let pageLimit = min(totalPages, 40)
                let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
                self.displayImageFromFlickrRandom(withPageNumber: randomPage, completion: { (success, image, error) in
                    guard error == nil else {
                        print("There was an error with your request: \(error)")
                        completion(false, nil, error)
                        return
                    }
                    
                    guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                        print("Your request returned a status code other than 2xx!")
                        return
                    }
                    
                    guard let photo = image else {return}
                    completion(true, photo, nil)
                })
                

            } else {print("error occurred")
                completion(false, nil, error)
            }
        }
        task.resume()
    }
    
    func displayImageFromFlickrRandom(withPageNumber: Int, completion: @escaping(_ success: Bool,_ image: [CodablePhoto]?,_ error: Error? ) -> Void) {
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.BoundingBox: bboxString(),
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback,
            Constants.FlickrParameterKeys.PerPage:
                Constants.FlickrParameterValues.PerPage,
            Constants.FlickrParameterKeys.Page: "\(withPageNumber)"
        ]
        
        // create session and request
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(methodParameters as [String : AnyObject]))
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print("There was an error with your request: \(error)")
                completion(false, nil, error)
                return
            }
            guard let data = data else {
                print("Error: \(error!)")
                completion(false, nil, error)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                return
            }
            
            if let jsonResults = try? JSONDecoder().decode(Stat.self, from: data) {
                
                guard let photo = jsonResults.photos.photo else {return}
                completion(true, photo, nil)
        
            } else {print("error occurred")
                completion(false, nil, error)
            }
        }
        task.resume()
    }
    
    private func bboxString() -> String {
        // ensure bbox is bounded by minimum and maximums
        
            let minimumLon = max(DestinationCoordinates.longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
            let minimumLat = max(DestinationCoordinates.latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
            let maximumLon = min(DestinationCoordinates.longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
            let maximumLat = min(DestinationCoordinates.latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
            return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    
    // MARK: Helper for Creating a URL from Parameters
    private func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    static let sharedInstance = APIClient()
}
