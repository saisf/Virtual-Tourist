//
//  APIClient.swift
//  Virtual Tourist
//
//  Created by Sai Leung on 6/11/18.
//  Copyright © 2018 Sai Leung. All rights reserved.
//

import Foundation

struct APIClient {
    
    func searchByLatLong() {
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.BoundingBox: bboxString(),
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
        ]
        displayImageFromFlickrBySearch(methodParameters as [String:AnyObject])
    }
    
    func displayImageFromFlickr(completion: @escaping(_ success: Bool,_ image: [Photo]?,_ error: Error? ) -> Void) {
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.BoundingBox: bboxString(),
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
        ]
        // create session and request
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(methodParameters as [String : AnyObject]))
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print("Error: \(error!)")
                completion(false, nil, error)
                return
            }
            guard let data = data else {
                print("Error: \(error!)")
                completion(false, nil, error)
                return
            }
            
            if let jsonResults = try? JSONDecoder().decode(Stat.self, from: data) {
                //                print(jsonResults.stat)
                ////                print(jsonResults.photos)
                //                print(jsonResults.photos.photo)
                guard let photo = jsonResults.photos.photo else {return}
                completion(true, photo, nil)
//                UserManager.sharedInstance.photos = photo
//                for url in UserManager.sharedInstance.photos {
//                    print(url.url_m)
                
                //                for url in photo {
                //                    print(url.url_m)
                //                }
                //                print(photo)
            } else {print("error occurred")
                completion(false, nil, error)
            }
        }
        // start the task!
        task.resume()
        
    }
    
    // MARK: Flickr API
    
    private func displayImageFromFlickrBySearch(_ methodParameters: [String: AnyObject]) {
        
        // create session and request
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(methodParameters))
        
        // create network request
        let task = session.dataTask(with: request) { (data, response, error) in
            
//
////            if error != nil {
//////                completion(false, nil, error)
////                print("Error")
////                return
////            }
////            DispatchQueue.main.async {
////                guard let data = data else {return}
////                guard let stat = try? JSONDecoder().decode(Stat.self, from: data) else {return}
////                let photos = stat.photos as Photos
////                let image = photos.photo as [Photo]
////                for pho in image {
////                    print(pho.url_m)
////                }
//////                let photo = photos.photo
//////                for image in photo {
//////                    print(image.url_m)
//////                    UserManager.sharedInstance.photos.append(image)
//////                }
//////                for x in UserManager.sharedInstance.photos {
//////                    print(x.url_m)
//////                }
////
////                //                let studentResults = jsonResults.results
//////                completion(true, studentResults, nil)
////            }
//
//            let parsedResult: [String:AnyObject]!
//            do {
//                parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
//            } catch {
//                print("Could not parse the data as JSON: '\(data)'")
//                return
//            }
            
             //if an error occurs, print it and re-enable the UI
//            func displayError(_ error: String) {
//                print(error)
////                performUIUpdatesOnMain {
////                    self.setUIEnabled(true)
////                    self.photoTitleLabel.text = "No photo returned. Try again."
////                    self.photoImageView.image = nil
////                }
//            }
//
//            /* GUARD: Was there an error? */
//            guard (error == nil) else {
//                displayError("There was an error with your request: \(error)")
//                return
//            }
//
//            /* GUARD: Did we get a successful 2XX response? */
//            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
//                displayError("Your request returned a status code other than 2xx!")
//                return
//            }

            /* GUARD: Was there any data returned? */
            guard let data = data else {
//                displayError("No data was returned by the request!")
                return
            }
//
//            // parse the data
//            let parsedResult: [String:AnyObject]!
//            do {
//                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
//                print(parsedResult)
//            } catch {
////                displayError("Could not parse the data as JSON: '\(data)'")
//                return
//            }
            
//            guard let data = data else {
//                //                displayError("No data was returned by the request!")
//                return
//            }
//
//            let parsedResult: Photos!
//                        do {
//                            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Photos
//                            print(parsedResult)
//                        } catch {
//                            return
//                        }
//
//            guard let jsonResults = try? JSONDecoder().decode(Stat.self, from: data) else {return}
            if let jsonResults = try? JSONDecoder().decode(Stat.self, from: data) {
//                print(jsonResults.stat)
////                print(jsonResults.photos)
//                print(jsonResults.photos.photo)
                guard let photo = jsonResults.photos.photo else {return}
                UserManager.sharedInstance.photos = photo
                for url in UserManager.sharedInstance.photos {
                    print(url.url_m)
                }
//                for url in photo {
//                    print(url.url_m)
//                }
//                print(photo)
            } else {print("error occurred")}
            
//            let results = jsonResults.photos
//            let photo = results.photo
//            let u = photo[0]
//            let url = u.url_m
//            print(url)
            
            
            
            
            
//            // START
            
//            guard let data = data else {
//                //                displayError("No data was returned by the request!")
//                return
//            }
//
//            let parsedResult: [String:AnyObject]!
//            do {
//                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
//                print(parsedResult["photos"]!)
//            } catch {
//                return
//            }
//
//            /* GUARD: Did Flickr return an error (stat != ok)? */
//            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
//                return
//            }
//
//            /* GUARD: Is "photos" key in our result? */
//            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
//                return
//            }
//            guard let photos = photosDictionary["photo"] as? [[String: AnyObject]] else {return}
//            let photo = photos[0] as [String: AnyObject]
//            let url = photo["url_m"] as! String
//            print(url)
//            // FINISH
            
            
            
            
            
            /* GUARD: Is "pages" key in the photosDictionary? */
//            guard let totalPages = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int else {
//                displayError("Cannot find key '\(Constants.FlickrResponseKeys.Pages)' in \(photosDictionary)")
//                return
//            }
            
//            guard let stat = try? JSONDecoder().decode(Stat.self, from: data) else {return}
//            let photos = stat.photos
//            let photo = photos.photo
//            let pho = photo[0].url_m as String
//            print(pho)
            
//            let parsedResult: [String:AnyObject]!
//            do {
//                let parsedResult = try JSONDecoder().decode(Stat.self, from: data)
//                print(parsedResult)
//            } catch {
//                //                displayError("Could not parse the data as JSON: '\(data)'")
//                return
//            }

            
            // parse the data
//            let parsedResult: [String:AnyObject]!
//            do {
//                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
//                print(parsedResult)
//            } catch {
//                //                displayError("Could not parse the data as JSON: '\(data)'")
//                return
//            }

//            /* GUARD: Did Flickr return an error (stat != ok)? */
//            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
//                displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
//                return
//            }
//
//            /* GUARD: Is "photos" key in our result? */
//            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
//                displayError("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
//                return
//            }
//
//            /* GUARD: Is "pages" key in the photosDictionary? */
//            guard let totalPages = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int else {
//                displayError("Cannot find key '\(Constants.FlickrResponseKeys.Pages)' in \(photosDictionary)")
//                return
//            }
            
            
            
            
            
            
//            // pick a random page!
//            let pageLimit = min(totalPages, 40)
//            let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
//            self.displayImageFromFlickrBySearch(methodParameters, withPageNumber: randomPage)
        }
        
        // start the task!
        task.resume()
    }
    
    private func bboxString() -> String {
        // ensure bbox is bounded by minimum and maximums
        
            let minimumLon = max(DestinationInformation.longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
            let minimumLat = max(DestinationInformation.latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
            let maximumLon = min(DestinationInformation.longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
            let maximumLat = min(DestinationInformation.latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
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
