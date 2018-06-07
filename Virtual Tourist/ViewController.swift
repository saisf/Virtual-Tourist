//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Sai Leung on 6/7/18.
//  Copyright © 2018 Sai Leung. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    var annotationCount = 0
    
    
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
    }

   
    @objc func addAnnotationOnLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            annotationCount += 1
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            print(coordinate)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            Annotaton.annotations.append(annotation)
            print("\(annotationCount)")
            
        }
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

