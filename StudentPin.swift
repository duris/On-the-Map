//
//  StudentPin.swift
//  On the Map
//
//  Created by Ross Duris on 8/12/15.
//  Copyright (c) 2015 duris.io. All rights reserved.
//

import MapKit

class StudentPin: NSObject, MKAnnotation {
    
    /* StudentPin properties */
    let title: String
    let subtitle: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        
        super.init()
    }
    
    /* Create a student pin from a StudentInformation object */
    static func createPin(student:StudentInformation) -> StudentPin {
        let title = "\(student.firstName) \(student.lastName)"
        let coordinate = CLLocationCoordinate2DMake(student.latitude, student.longitude)
        let subtitle = student.mediaURL
        let studentPin = StudentPin(title: title, subtitle: subtitle, coordinate: coordinate)
        return studentPin
    }
    
}
