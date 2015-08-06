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

    override func viewDidLoad() {
        super.viewDidLoad()


    }
    
    @IBAction func logout() {
        UdacityClient.sharedInstance().logout(self)
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! UIViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }

}
