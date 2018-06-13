//
//  CollectionViewController.swift
//  Virtual Tourist
//
//  Created by Sai Leung on 6/11/18.
//  Copyright © 2018 Sai Leung. All rights reserved.
//

import UIKit
import MapKit

class CollectionViewController: UIViewController, MKMapViewDelegate, UICollectionViewDataSource,UICollectionViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Disable user map interaction
        mapView.isUserInteractionEnabled = false
        
        
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
        
//        APIClient.sharedInstance.searchByLatLong()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! CollectionViewCell
        

        APIClient.sharedInstance.displayImageFromFlickr { (success, photos, error) in
            guard error == nil else {
                "Error: \(error!)"
                return
            }
            if success {
                
                    guard let photos = photos else {return}
                    let flickrPhoto = photos[indexPath.row]
                    let url = URL(string: flickrPhoto.url_m)
                    let data = try? Data(contentsOf: url!)
                DispatchQueue.main.async {
                    cell.collectionImage.image = UIImage(data: data!)
                }
            }
            
        }
//        if UserManager.sharedInstance.photos.count > 1 {
//            let flickrPhoto = UserManager.sharedInstance.photos[indexPath.row]
//            let url = URL(string: flickrPhoto.url_m)
//            let data = try? Data(contentsOf: url!)
//            cell.collectionImage.image = UIImage(data: data!)
//            print("success")
//        } else {
//            print("not success")
//        }
        
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var pinView = mapView as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
        pinView?.canShowCallout = true
        return pinView
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
