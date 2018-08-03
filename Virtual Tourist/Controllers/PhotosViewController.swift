//
//  CollectionViewController.swift
//  Virtual Tourist
//
//  Created by Sai Leung on 6/11/18.
//  Copyright © 2018 Sai Leung. All rights reserved.
//

import UIKit
import MapKit
import SDWebImage
import CoreData

class PhotosViewController: UIViewController, MKMapViewDelegate, UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newPhotosAndDeletingLabels: UIButton!
    
    var manager: SDWebImageManager = SDWebImageManager.shared()
    var manageObjectContext: NSManagedObjectContext?
    var downloadedPhotos: [Photo]?
    var deletingPhotos = [Photo]()
    var deletingPin = Pin()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
        newPhotosAndDeletingLabels.titleLabel?.textAlignment = .center
        
        // Disable user map interaction
        mapView.isUserInteractionEnabled = false
        
        // CORE DATA
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        manageObjectContext = appDelegate.persistentContainer.viewContext
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Add map pin annotation
        let annotation = MKPointAnnotation()
        let coordinate = CLLocationCoordinate2DMake(DestinationCoordinates.latitude, DestinationCoordinates.longitude)
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        // MARK: Set map region
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let UScenterCoordinate = CLLocationCoordinate2D(latitude: DestinationCoordinates.latitude, longitude: DestinationCoordinates.longitude)
        let region = MKCoordinateRegionMake(UScenterCoordinate, span)
        mapView.setRegion(region, animated: true)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var photos: [Photo]?
        do {
            let request: NSFetchRequest<Pin> = Pin.fetchRequest()
            request.predicate = NSPredicate(format: "latitude CONTAINS \(DestinationCoordinates.latitude) AND longitude CONTAINS \(DestinationCoordinates.longitude)")
            let results = try manageObjectContext?.fetch(request) as! [Pin]
            guard let firstResult = results.first else {return 0}
            deletingPin = firstResult
            photos = firstResult.photos?.allObjects as! [Photo]
        } catch {
            fatalError("Error in retrieving Pin item")
        }
        return photos?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! PhotosCollectionViewCell
//        cell.contentView.backgroundColor = UIColor.darkGray
//        cell.collectionImage.sd_setIndicatorStyle(.gray)
//        cell.collectionImage.sd_addActivityIndicator()
        var photos: [Photo]?
        var photo: Photo?
            do {
                let request: NSFetchRequest<Pin> = Pin.fetchRequest()
                request.predicate = NSPredicate(format: "latitude CONTAINS \(DestinationCoordinates.latitude) AND longitude CONTAINS \(DestinationCoordinates.longitude)")
                let results = try self.manageObjectContext?.fetch(request)
                if let results = results {
                    if let firstResult = results.first {
                        photos = firstResult.photos?.allObjects as? [Photo]
                        if let photos = photos {
                            let sortedPhotos = photos.sorted{ $0.url! < $1.url! }
                            self.downloadedPhotos = sortedPhotos
                            photo = sortedPhotos[indexPath.row]
                        }
                    }
                }
            } catch {
                fatalError("Error in retrieving Pin item")
            }
        if deletingPhotos.count == 0 {
            cell.contentView.alpha = 1.0
        }
        DispatchQueue.main.async {
            if let image = photo?.image {
//            cell.collectionImage.sd_removeActivityIndicator()
//            cell.collectionImage.image = UIImage(data: (photo?.image)!)
                cell.configureCell(image: image)
            }
        }
        print("Collection cell successful")
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? PhotosCollectionViewCell
        if (cell?.isSelected)! {
            guard let downloadedPhotos = downloadedPhotos else {return}
            deletingPhotos.append(downloadedPhotos[indexPath.row])
            if deletingPhotos.count == 0 {
                newPhotosAndDeletingLabels.setTitle("New Collection", for: .normal)
            } else {
                newPhotosAndDeletingLabels.setTitle("Remove Selected Pictures", for: .normal)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? PhotosCollectionViewCell
        if (cell?.isSelected)! {
            } else {
                var num = 0
                guard let downloadedPhotos = downloadedPhotos else {return}
                for x in 0...deletingPhotos.count - 1 {
                    if deletingPhotos[x] == downloadedPhotos[indexPath.row] {
                        num = x
                        deletingPhotos.remove(at: num)
                        if deletingPhotos.count == 0 {
                            newPhotosAndDeletingLabels.setTitle("New Collection", for: .normal)
                        } else {
                            newPhotosAndDeletingLabels.setTitle("Remove Selected Pictures", for: .normal)
                        }
                        return
                    }
                }
            }
    }

    @IBAction func newPhotosAndDeletingButton(_ sender: UIButton) {
        if deletingPhotos.count > 0 {
            for photo in deletingPhotos {
                manageObjectContext?.delete(photo)
            }
            do {
                try manageObjectContext?.save()
                collectionView.reloadData()
                newPhotosAndDeletingLabels.setTitle("New Collection", for: .normal)
                deletingPhotos = [Photo]()

            } catch {
                print("Something wrong to delete photos")
            }
        } else {
            manageObjectContext?.delete(deletingPin)
            do {
                try manageObjectContext?.save()
                collectionView.reloadData()
            } catch {
                print("Photos deleted unsuccessfully")
            }
            
            APIClient.sharedInstance.displayImageFromFlickr { (firstSuccess, photos, error) in
                guard error == nil else {
                    print("Error: \(error!)")
                    return
                }
                
                if firstSuccess == true {
                    guard let photos = photos else {return}
                    ViewController.shared.generateURLFromPhotos(photos: photos, completion: { (secondSuccess, urls) in
                        //                        print(urls)
                        if secondSuccess == true {
                            guard let urls = urls else {
                                return
                            }
                            let pinEntity = NSEntityDescription.entity(forEntityName: "Pin", in: self.manageObjectContext!)
                            let pin = Pin(entity: pinEntity!, insertInto: self.manageObjectContext)
                            pin.latitude = DestinationCoordinates.latitude
                            pin.longitude = DestinationCoordinates.longitude
                            for url in urls {
                                self.manager.imageDownloader?.downloadImage(with: url, options: .highPriority, progress: nil, completed: { (image, data, error, success) in
                                    guard error == nil else {
                                        return
                                    }
                                    guard let image = image else {
                                        return
                                    }
                                    guard let data = UIImagePNGRepresentation(image) else {
                                        print("Can't convert image to data to be saved for core data Photo")
                                        return
                                    }
                                    
                                    do {
                                        let photoEntity = NSEntityDescription.entity(forEntityName: "Photo", in: self.manageObjectContext!)
                                        let photo = Photo(entity: photoEntity!, insertInto: self.manageObjectContext)
                                        photo.image = data
                                        photo.url = url.absoluteString
                                        pin.addToPhotos(photo)
                                        try self.manageObjectContext?.save()
                                        self.collectionView.reloadData()
                                        print("Work out")
                                    } catch  {
                                        print("NOT working out")
                                    }
                                    print("Image data saved successful")
                                })
                            }
                        }
                    })
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var pinView = mapView as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
        pinView?.canShowCallout = true
        return pinView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width/3.17
        let height = width
        return CGSize(width: width, height: height)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

