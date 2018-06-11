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
    @IBOutlet weak var edit: UIBarButtonItem!
    @IBOutlet weak var tapPinsLabel: UILabel!
    var editingMode = false
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
        
        editButtonTitleChange()
        
        tapPinsLabel.isHidden = true
        
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
    
    func showAlert() {
        let alert = UIAlertController(title: "Alert", message: "Wait Please!", preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { (_) in
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func addAnnotationOnLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            print(coordinate)
            if self.editingMode == false {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            Annotaton.annotations.append(annotation)
            print("\(annotationCount)")
            annotationCount += 1
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if editingMode {
            self.mapView.removeAnnotation(view.annotation!)
        } else {
            performSegue(withIdentifier: "ToCollectionViewController", sender: nil)
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

// Mark: Make labels fade in/out
extension UIView {
    func fadeIn(duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {self.alpha = 1.0}, completion: completion)
    }
    func fadeOut(duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {self.alpha = 0.0}, completion: completion)
    }

}

