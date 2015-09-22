//
//  MapViewController.swift
//  On the Map
//
//  Created by Ross Duris on 8/6/15.
//  Copyright (c) 2015 duris.io. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: SharedViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapActivityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set mapView delegate
        mapView.delegate = self                
        
        // Load student pins
        loadStudentPins()
        
        // Configure navigation items
        configureNavBarUI()
    }
    
    
    func loadStudentPins(){
        //Start loading
        toggleLoading(true, indicator: mapActivityIndicator, view: mapView)
        ParseClient.sharedInstance().getStudentLocations() { (success, errorString) in
            if success {
                self.createStudentPins()
            } else {
                self.alertError(errorString, viewController: self)
            }
            //Stop loading
            self.toggleLoading(false, indicator: self.mapActivityIndicator, view: self.mapView)
        }
    }
    
    
    func createStudentPins()  {
        dispatch_async(dispatch_get_main_queue()) {
            for location in ParseClient.studentLocations {
                //Add each student location to the mapView
                self.mapView.addAnnotation(StudentPin.createPin(location))
            }
        }
    }

    func refresh() {
        //Remove all annotations
        for annotation in mapView.annotations{
            self.mapView.removeAnnotation(annotation as! MKAnnotation)
        }
        //Reload the data
        loadStudentPins()
    }

    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!,
        calloutAccessoryControlTapped control: UIControl!) {
            //Open students mediaURL when accessory is tapped
            let pin = view.annotation as! StudentPin
            let url = pin.subtitle
            handleURL(url)
    }
    
    //Concepts from RayWenderlich.com
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        let annotation = MKPointAnnotation()
        let identifier = "pin"
        var view: MKPinAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
            as? MKPinAnnotationView { 
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
