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

class PhotosViewController: UIViewController, MKMapViewDelegate, UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newPhotosAndDeletingLabels: UIButton!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
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
        let space: CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
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
        return 21
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! PhotosCollectionViewCell
        var photos: [Photo]?
        var photo: Photo?
        cell.contentView.backgroundColor = UIColor.darkGray
        cell.collectionImage.sd_setIndicatorStyle(.gray)
        cell.collectionImage.sd_addActivityIndicator()

            do {
                let epsilon = 0.000000001;
                let request: NSFetchRequest<Pin> = Pin.fetchRequest()
                request.predicate = NSPredicate(format: "latitude > %lf AND latitude < %lf AND longitude > %lf AND longitude < %lf", DestinationCoordinates.latitude - epsilon, DestinationCoordinates.latitude + epsilon, DestinationCoordinates.longitude - epsilon, DestinationCoordinates.longitude + epsilon)
                let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: true)
                request.sortDescriptors = [sortDescriptor]
                let results = try self.manageObjectContext?.fetch(request)
                if let results = results {
                    if let firstResult = results.first {
                        deletingPin = firstResult
                        photos = firstResult.photos?.allObjects as? [Photo]
                        if let photos = photos {
                            let sortedPhotos = photos.sorted{ $0.url! < $1.url! }
                            self.downloadedPhotos = sortedPhotos
                            if indexPath.row < sortedPhotos.count {
                                photo = sortedPhotos[indexPath.row]
                            }
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
                cell.collectionImage.sd_removeActivityIndicator()
                cell.configureCell(image: image)
                cell.collectionImage.sd_removeActivityIndicator()
            }
        }
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
                print("Core data deleting photos unsuccessfully")
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
                    guard let photos = photos else {
                        print("Downloaded photos are nil")
                        return
                    }
                    CoreDataEntities.sharedInstance.generateURLFromPhotos(photos: photos, completion: { (success, urls) in
                        if success {
                            guard let urls = urls else {
                                print("Downloaded urls are nil")
                                return
                            }
                            guard let manageObjectContext = self.manageObjectContext else {return}
                            CoreDataEntities.sharedInstance.generateCoreDataPhotosEntity(urls: urls, latitude: DestinationCoordinates.latitude, longitude: DestinationCoordinates.longitude, manageObjectContext: manageObjectContext, collectionView: self.collectionView)
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
}


