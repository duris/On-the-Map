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
    var students = [ParseStudent]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Get students data */
        ParseClient.sharedInstance().getStudentData() { (students, errorString) in
            self.students = students
            dispatch_async(dispatch_get_main_queue()) {

            }
        }
    }
    
    @IBAction func logout() {
        UdacityClient.sharedInstance().logout(self)
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! UIViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }

}
