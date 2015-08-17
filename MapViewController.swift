//
//  MapViewController.swift
//  On the Map
//
//  Created by Ross Duris on 8/6/15.
//  Copyright (c) 2015 duris.io. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    var students = [StudentInformation]()
    let regionRadius: CLLocationDistance = 1000

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        /* Get students data */
        ParseClient.sharedInstance().getStudentData() { (students, errorString) in
            self.students = students
            dispatch_async(dispatch_get_main_queue()) {
                for student in students {
                    self.createPin(student)
                }
            }
        }

    }

    @IBAction func logout() {
        UdacityClient.sharedInstance().logout(self)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!,
        calloutAccessoryControlTapped control: UIControl!) {
            let pin = view.annotation as! StudentPin
            let url = pin.mediaURL
            handleURL(url)
    }
    
    func createPin(student:StudentInformation) {
        let title = "\(student.firstName) \(student.lastName)"
        let coordinate = CLLocationCoordinate2DMake(student.latitude, student.longitude)
        let mediaURL = student.mediaURL
        let studentPin = StudentPin(title: title, coordinate: coordinate, mediaURL: mediaURL)
        mapView.addAnnotation(studentPin)
    }
    
    func handleURL(url: String) {
     UIApplication.sharedApplication().openURL(NSURL(string: url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!)        
    }
}
