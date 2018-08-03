//
//  CoreDataEntitiesGeneration.swift
//  Virtual Tourist
//
//  Created by Sai Leung on 8/3/18.
//  Copyright © 2018 Sai Leung. All rights reserved.
//

import Foundation
import CoreData
import SDWebImage

struct CoreDataEntities {
    static let sharedInstance = CoreDataEntities()
    let manager: SDWebImageManager = SDWebImageManager.shared()
    
    
    // MARK: CORE DATA function to save Pin and Photo
    func generateCoreDataPhotosEntity(urls: [URL], latitude: Double, longitude: Double, manageObjectContext: NSManagedObjectContext, collectionView: UICollectionView?) {
        
        let pinEntity = NSEntityDescription.entity(forEntityName: "Pin", in: manageObjectContext)
        let pin = Pin(entity: pinEntity!, insertInto: manageObjectContext)
        pin.latitude = latitude
        pin.longitude = longitude
        DispatchQueue.main.async {
            for url in urls {
                self.manager.imageDownloader?.downloadImage(with: url, options: .highPriority, progress: nil, completed: { (image, data, error, success) in
                    guard error == nil else {
                        print("Error occurs downloading image")
                        return
                    }
                    guard let image = image else {
                        print("Downloaded image is nil")
                        return
                    }
                    guard let data = UIImagePNGRepresentation(image) else {
                        print("Can't convert image to data to be saved for core data Photo")
                        return
                    }
                    do {
                        let photoEntity = NSEntityDescription.entity(forEntityName: "Photo", in: manageObjectContext)
                        let photo = Photo(entity: photoEntity!, insertInto: manageObjectContext)
                        photo.image = data
                        photo.url = url.absoluteString
                        pin.addToPhotos(photo)
                        try manageObjectContext.save()
                        if collectionView != nil {
                            collectionView?.reloadData()
                        }
                    } catch  {
                        print("NOT working out")
                    }
                })
            }
        }
    }
    
    // MARK: Extracting urls from downloaded photos data
    func generateURLFromPhotos(photos: [CodablePhoto], completion: @escaping(_ success: Bool,_ url: [URL]?) -> Void) {
        var urls = [URL]()
        for photo in photos {
            guard let newUrl = URL(string: photo.url_m) else {
                print("Can't download photo url")
                completion(false, nil)
                return
            }
            urls.append(newUrl)
        }
        completion(true, urls)
    }
}
