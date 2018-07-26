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

class CollectionViewController: UIViewController, MKMapViewDelegate, UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    var imageURLString = [String]()
    var images = [CodablePhoto]()
    var manager: SDWebImageManager = SDWebImageManager.shared()
    var count = 0
    var result = [NSManagedObject]()
    var manageObjectContext: NSManagedObjectContext?
    
    var annotations = [NSManagedObject]()
    var photos = [NSManagedObject]()

    var downloadedPhotos: [Photo]?
    var deletingPhotos = [Photo]()
    var tapped = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
        
        // Disable user map interaction
        mapView.isUserInteractionEnabled = false
        
        // CORE DATA
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        manageObjectContext = appDelegate.persistentContainer.viewContext
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Add pin annotation
        let annotation = MKPointAnnotation()
        let coordinate = CLLocationCoordinate2DMake(DestinationInformation.latitude, DestinationInformation.longitude)
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        // MARK: Set map region
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let UScenterCoordinate = CLLocationCoordinate2D(latitude: DestinationInformation.latitude, longitude: DestinationInformation.longitude)
        let region = MKCoordinateRegionMake(UScenterCoordinate, span)
        mapView.setRegion(region, animated: true)
        UserManager.sharedInstance.photos.removeAll()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var photos: [Photo]?
        do {
            
            let latitude = DestinationInformation.latitude
            let longitude = DestinationInformation.longitude
            let num = 44.0048505275322
            let request: NSFetchRequest<Pin> = Pin.fetchRequest()
            request.predicate = NSPredicate(format: "latitude CONTAINS \(latitude) AND longitude CONTAINS \(longitude)")
            let results = try manageObjectContext?.fetch(request) as! [Pin]
            guard results != nil else {return 0}
            print(results.count)
            print(results)
            guard let firstResult = results.first else {return 0}
            print(firstResult.latitude)
            print(firstResult.longitude)
            photos = firstResult.photos?.allObjects as! [Photo]
            print("Photos Count: \(photos?.count)")
        } catch {
            fatalError("Error in retrieving Pin item")
        }
        return photos?.count ?? 0
    }
    
    private func fetchRecordsForEntity(_ entity: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext){
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        
        // Helpers
        
        
        do {
            // Execute Fetch Request
            let records = try managedObjectContext.fetch(fetchRequest)
            
            if let records = records as? [NSManagedObject] {
                result = records
            }
            
        } catch {
            print("Unable to fetch managed objects for entity \(entity).")
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var photos: [Photo]?
        var photo: Photo?
        do {
            let latitude = DestinationInformation.latitude
            let longitude = DestinationInformation.longitude
            let num = 44.0048505275322
            let request: NSFetchRequest<Pin> = Pin.fetchRequest()
            request.predicate = NSPredicate(format: "latitude CONTAINS \(latitude) AND longitude CONTAINS \(longitude)")
            let results = try manageObjectContext?.fetch(request)
            if let results = results {
                print(results.count)
                print(results)
                if let firstResult = results.first {
                    print(firstResult.latitude)
                    print(firstResult.longitude)
                    photos = firstResult.photos?.allObjects as? [Photo]
                    print("Photos Count: \(photos?.count)")
                    if let photos = photos {
                        let sortedPhotos = photos.sorted{ $0.url! < $1.url! }
                        downloadedPhotos = sortedPhotos
                        photo = sortedPhotos[indexPath.row]
//                        photo = photos[indexPath.row]
                    }
                }
            }
        } catch {
            fatalError("Error in retrieving Pin item")
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! CollectionViewCell

        let url = URL(string: (photo?.url)!)

        
        cell.collectionImage.sd_setShowActivityIndicatorView(true)
        cell.collectionImage.sd_setIndicatorStyle(.gray)
        cell.collectionImage.image = UIImage(data: (photo?.image)!)
    
//        cell.collectionImage.sd_setImage(with: url!)

        print("Collection cell successful")
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell
        
//        guard let image = cell?.collectionImage.image else {return}
//        let imageData = UIImagePNGRepresentation(image)
        
//        cell?.toggleSelected()
        if (cell?.isSelected)! {
//            cell?.backgroundColor = UIColor.gray
            cell?.contentView.alpha = 0.5
//
            guard let downloadedPhotos = downloadedPhotos else {return}
            deletingPhotos.append(downloadedPhotos[indexPath.row])
            print("Downloaded count: \(downloadedPhotos.count)")
            print("Deleted count: \(deletingPhotos.count)")
            print(indexPath.row)
        } else {
//            cell?.backgroundColor = nil
//            var num = 0
//            print("There's something in deletingPhotos")
//            guard let downloadedPhotos = downloadedPhotos else {return}
//                for x in 0...deletingPhotos.count - 1 {
////                    if deletingPhotos.count - 1 >= indexPath.row {
//                        if deletingPhotos[x] == downloadedPhotos[indexPath.row] {
//                            print("URL: \(String(describing: deletingPhotos[x].url))")
//                            num = x
//                            self.deletingPhotos.remove(at: num)
//                        }
////                    }
//                }
//            print("Deleted count: \(deletingPhotos.count)")
        }
        
        
//        if tapped == false {
//            cell?.contentView.backgroundColor = UIColor.red
////            guard let downloadedPhotos = downloadedPhotos else {return}
//            deletingPhotos.append(downloadedPhotos![indexPath.row])
//            print("Downloaded count: \(downloadedPhotos?.count)")
//            print("Deleted count: \(deletingPhotos.count)")
//            print(indexPath.row)
//            tapped = true
//        } else {
//            var num = 0
//            cell?.contentView.backgroundColor = nil
//            print(deletingPhotos.count)
//            print("There's something in deletingPhotos")
//            guard let downloadedPhotos = downloadedPhotos else {return}
//                for x in 0...deletingPhotos.count - 1 {
////                    if deletingPhotos.count - 1 >= indexPath.row {
//                        if deletingPhotos[x] == downloadedPhotos[indexPath.row] {
//                            print("URL: \(String(describing: deletingPhotos[x].url))")
//                            num = x
//                            self.deletingPhotos.remove(at: num)
//                        }
////                    }
//                }
//            print("Deleted count: \(deletingPhotos.count)")
//            tapped = false
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell
//        cell?.toggleSelected()
        
//        if tapped == false {
//            tapped = false
//        } else {
//            tapped = true
//        }
        if (cell?.isSelected)! {
//            cell?.backgroundColor = UIColor.gray
            cell?.contentView.alpha = 0.5

        } else {
//            cell?.backgroundColor = nil
            cell?.contentView.alpha = 1
            var num = 0
            print("There's something in deletingPhotos")
            guard let downloadedPhotos = downloadedPhotos else {return}
                for x in 0...deletingPhotos.count - 1 {
//                    if deletingPhotos.count - 1 >= indexPath.row {
                        if deletingPhotos[x] == downloadedPhotos[indexPath.row] {
                            print("URL: \(String(describing: deletingPhotos[x].url))")
                            num = x
                            self.deletingPhotos.remove(at: num)
                            print("Deleted count: \(deletingPhotos.count)")
                            return
                        }
//                    }
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

