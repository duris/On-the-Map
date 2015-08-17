//
//  MapAnnotationView.swift
//  On the Map
//
//  Created by Ross Duris on 8/11/15.
//  Copyright (c) 2015 duris.io. All rights reserved.
//

import MapKit

extension MapViewController: MKMapViewDelegate {
    

    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        let annotation = MKPointAnnotation()
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView { // 2
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {

                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -9, y: 0)
                view.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIView
            }
            return view                
    }
    
}
