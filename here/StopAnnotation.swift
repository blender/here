//
//  StopAnnotation.swift
//  here
//
//  Created by Tommaso Piazza on 11/08/15.
//  Copyright (c) 2015 Alloc Init. All rights reserved.
//

import UIKit
import MapKit

class StopAnnotation: NSObject, MKAnnotation {
   
    var coordinate: CLLocationCoordinate2D
    
    var title: String!
    var subtitle: String!
    
    init(latitude:Double, longitude:Double, title:String, subtitle:String) {
        
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude:longitude)
        self.title = title
        self.subtitle = subtitle
        super.init()
    }
}
