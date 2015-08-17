//
//  StudentPin.swift
//  On the Map
//
//  Created by Ross Duris on 8/12/15.
//  Copyright (c) 2015 duris.io. All rights reserved.
//

import MapKit

class StudentPin: NSObject, MKAnnotation {
    
    let title: String
    let coordinate: CLLocationCoordinate2D
    let mediaURL: String
    
    init(title: String, coordinate: CLLocationCoordinate2D, mediaURL: String) {
        self.title = title
        self.coordinate = coordinate
        self.mediaURL = mediaURL
        
        super.init()
    }
    
}
