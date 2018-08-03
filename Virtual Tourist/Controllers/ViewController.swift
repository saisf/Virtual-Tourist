//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Sai Leung on 6/7/18.
//  Copyright © 2018 Sai Leung. All rights reserved.
//

import UIKit
import MapKit
import SDWebImage
import CoreData

class ViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var edit: UIBarButtonItem!
    @IBOutlet weak var tapPinsLabel: UILabel!
    
    static let shared = ViewController()
    var editingMode = false
    var annotationCount = 0
    
    var annotations = [NSManagedObject]()
    var photos = [NSManagedObject]()
    var pho: NSManagedObject?
    var manageObjectContext: NSManagedObjectContext?
    var photo: Photo?
    var pin: Pin?
    var pins: [Pin]?
    
    
    var images = [UIImage]()
    var imageURLString = [String]()
    var manager: SDWebImageManager = SDWebImageManager.shared()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        // MARK: Gesture recognizer to allow user to add pin when long pressed
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotationOnLongPress(gesture:)))
        longPressGesture.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressGesture)
        
        // MARK: Set map region
        let span = MKCoordinateSpanMake(18, 18)
        let UScenterCoordinate = CLLocationCoordinate2D(latitude: 39.8283, longitude: -98.5795)
        let region = MKCoordinateRegionMake(UScenterCoordinate, span)
        mapView.setRegion(region, animated: true)
        
        editButtonTitleChange()
        
        tapPinsLabel.isHidden = true
        
        // CORE DATA
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        manageObjectContext = appDelegate.persistentContainer.viewContext
//        deletePinData()
//        deletePhotoData()
        loadPinData()
        guard let pins = pins else {return}
        addMapViewAnnotation(pins: pins)
        loadPhotoData()
        manageObjectContext?.refreshAllObjects()
    }
    
    func deletePinData() {
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Pin")
        do {
            let results = try manageObjectContext?.fetch(request)
            guard results != nil else {return}
            print("Pin result count: \(results?.count)")
            print(results)
            for result in results! {
                manageObjectContext?.delete(result)
                print("Pin Delete successfully")
            }
            try manageObjectContext?.save()
        } catch {
            print("Pin Delete unsuccessfully")
        }
    }
    
    func deletePhotoData() {
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Photo")
        do {
            let results = try manageObjectContext?.fetch(request)
            guard results != nil else {return}
            print(results?.count)
            for result in results! {
                manageObjectContext?.delete(result)
                print("Photo Delete successfully")
            }
            try manageObjectContext?.save()
            
            
        } catch {
            print("Photo Delete unsuccessfully")
        }
    }
    
    func loadPinData() {
        do {
            let request: NSFetchRequest<Pin> = Pin.fetchRequest()
            let results = try manageObjectContext?.fetch(request) as! [Pin]
            guard results != nil else {return}
            pins = results
            print("PIN Count: \(results.count)")
            print("RESULTS: \(results)")
            guard let firstResult = results.first else {return}
            print(firstResult.latitude)
            print(firstResult.longitude)
        } catch {
            fatalError("Error in retrieving Pin item")
        }
    }
    
    func loadPhotoData() {
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
        do {
            let results = try manageObjectContext?.fetch(request)
            guard results != nil else {return}
            print("PHOTO Count: \(results?.count)")
        } catch {
            fatalError("Error in retrieving Photo item ")
        }
        
    }
    
    func addMapViewAnnotation(pins: [Pin]) {
        for pin in pins {
            let pinLocation = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = pinLocation
            mapView.addAnnotation(annotation)
        }
    }
    
    // MARK: Delete annotation when tap its pin
    @IBAction func editAnnotationButton(_ sender: UIBarButtonItem) {
        tapPinsLabel.isHidden = false
        editButtonTitleChange()
        if editingMode {
            tapPinsLabel.fadeIn(duration: 0.5, delay: 0.0, completion: { (_) in
                Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false, block: { (_) in
                    self.tapPinsLabel.fadeOut()
                })
            })
        } else {
            tapPinsLabel.fadeOut()
        }
    }
    
    // MARK: Modify edit button title
    func editButtonTitleChange() {
        if edit.title == "Edit" {
            edit.title = "Done"
            edit.tintColor = .red
            editingMode = true
        } else {
            edit .title = "Edit"
            edit.tintColor = UIColor(red: 0.0, green: 122/255, blue: 1.0, alpha: 1)
            editingMode = false
        }
    }
    
    // MARK: CORE DATA function to save Pin and Photo
    func generateCoreDataPhotosEntity(urls: [URL], latitude: Double, longitude: Double) {
        let pinEntity = NSEntityDescription.entity(forEntityName: "Pin", in: manageObjectContext!)
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
                    let photoEntity = NSEntityDescription.entity(forEntityName: "Photo", in: self.manageObjectContext!)
                    let photo = Photo(entity: photoEntity!, insertInto: self.manageObjectContext)
                    photo.image = data
                    photo.url = url.absoluteString
                    pin.addToPhotos(photo)
                    try self.manageObjectContext?.save()
                } catch  {
                    print("NOT working out")
                }
                print("Image data saved successfully")
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
    
    // MARK: LongPress Gesture function
    @objc func addAnnotationOnLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            let latitude = Double(coordinate.latitude)
            let longitude = Double(coordinate.longitude)
            DestinationCoordinates.latitude = latitude
            DestinationCoordinates.longitude = longitude
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
                    self.generateURLFromPhotos(photos: photos, completion: { (secondSuccess, urls) in
                        if secondSuccess == true {
                            guard let urls = urls else {
                                print("Downloaded urls are nil")
                                return
                            }
                            self.generateCoreDataPhotosEntity(urls: urls, latitude: latitude, longitude: longitude)
                        }
                    })
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let latitude: Double = view.annotation?.coordinate.latitude else {return}
        guard let longitude: Double = view.annotation?.coordinate.longitude else {return}

        if editingMode {
            self.mapView.removeAnnotation(view.annotation!)
            let request: NSFetchRequest<Pin> = Pin.fetchRequest()
            request.predicate = NSPredicate(format: "latitude CONTAINS \(latitude) AND longitude CONTAINS \(longitude)")
            let results = try! manageObjectContext?.fetch(request)
            for result in results! {
                manageObjectContext?.delete(result)
            }
            do {
                try manageObjectContext?.save()
            } catch let error as Error {
                print("Pin Delete unsuccessfully, error: \(error)")
            }
        } else {
            DestinationCoordinates.latitude = Double(latitude)
            DestinationCoordinates.longitude = Double(longitude)
            performSegue(withIdentifier: "ToCollectionViewController", sender: nil)
        }
        mapView.deselectAnnotation(view.annotation, animated: false)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.animatesDrop = true
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
}

// Mark: Make labels fade in/out
extension UIView {
    func fadeIn(duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {self.alpha = 1.0}, completion: completion)
    }
    func fadeOut(duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {self.alpha = 0.0}, completion: completion)
    }

}

