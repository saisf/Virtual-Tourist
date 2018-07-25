//
//  Annotation.swift
//  Virtual Tourist
//
//  Created by Sai Leung on 6/7/18.
//  Copyright © 2018 Sai Leung. All rights reserved.
//

import Foundation
import MapKit
import CoreData

class Annotaton: NSObject {
    static var annotations = [MKPointAnnotation]()
    
    static var pins = [NSManagedObject]()
    
    static var photos = [NSManagedObject]()
    
    static var testPhotos = [UIImage]()
}
