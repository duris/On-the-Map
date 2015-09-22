//
//  InformationPostingViewController.swift
//  On the Map
//
//  Created by Ross Duris on 8/20/15.
//  Copyright (c) 2015 duris.io. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class InformationPostingViewController: SharedViewController, UITextFieldDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var geoActivityIndicator:UIActivityIndicatorView!
    @IBOutlet weak var locationTextFeild:UITextField!
    @IBOutlet weak var mediaURLTextFeild:UITextField!
    @IBOutlet weak var mapView:MKMapView!
    @IBOutlet weak var submitButton:UIButton!
    @IBOutlet weak var topView:UIView!
    @IBOutlet weak var bottomView:UIView!
    @IBOutlet weak var cancelButton:UIButton!
    @IBOutlet weak var topTitleLabel:UILabel!
    let defaultText = "Tap Here to Start"
    let defaultMediaText = "Tap Here to Enter a Link"
    let regionRadius: CLLocationDistance = 1000
    var location: CLLocation!
    var geocoder = CLGeocoder()

    override func viewDidLoad() {
        super.viewDidLoad()                        
        
        // Configure the user interface
        configureUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        addKeyboardDismissRecognizer()
    }
    
    override func viewWillDisappear(animated: Bool) {
        removeKeyboardDismissRecognizer()
    }
    
    @IBAction func cancelPost() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitButtonTouch() {
        let mapString = locationTextFeild.text
        let mediaURL = mediaURLTextFeild.text
        
        //If submit title is present attempt to submit post
        //Else if find on map title is present attemp to geocode the string
        if submitButton.titleLabel?.text == "Submit" {
            if mediaURL != defaultMediaText && !mediaURL.isEmpty{
                if let url = NSURL(string: mediaURL){
                    if UIApplication.sharedApplication().canOpenURL(url){
                        
                        //Prepare a StudentInformation object
                        var student = StudentInformation(dictionary: [
                            "uniqueKey": UdacityClient.User.uniqueKey,
                            "firstName": UdacityClient.User.firstName,
                            "lastName": UdacityClient.User.lastName,
                            "latitude": location.coordinate.latitude,
                            "longitude": location.coordinate.longitude,
                            "mediaURL": mediaURL,
                            "mapString": mapString
                            ])
                        

                        //If a location does not exist yet create one or else ask to overwrite
                        if ParseClient.locationId == "" {
                            //Post student location
                            ParseClient.sharedInstance().postStudentLocation(student) { (success, errorString) in
                                if success {
                                    self.dismissViewControllerAnimated(true, completion: nil)
                                } else {
                                    self.alertError(errorString, viewController: self)
                                }
                            }
                        } else {
                            //Update existing student location
                            ParseClient.sharedInstance().updateStudentLocation(ParseClient.locationId, student: student) { (success, errorString) in
                                if success {
                                    self.dismissViewControllerAnimated(true, completion: nil)
                                } else {
                                    self.alertError(errorString, viewController: self)
                                }
                            }
                        }
                        
                    } else {
                        alertError("The link you entered is not valid.", viewController: self)
                    }
                }
            }
        } else{
            if mapString != defaultText && !mapString.isEmpty {
                
                //Geocode the address and start loading
                toggleLoading(true, indicator: geoActivityIndicator, view: view)
                geocoder.geocodeAddressString(mapString, completionHandler: geocodingCompleted)
            }
        }

    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        //Clear textField
        if textField.text == defaultText || textField.text == defaultMediaText {
            textField.text = ""
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        //If the textField is empty set to default
        if textField.text.isEmpty {
            locationTextFeild.text = defaultText
            mediaURLTextFeild.text = defaultMediaText
        }
    }

    func configureUI(){
        //Configure delegates and defaults
        locationTextFeild.delegate = self
        mediaURLTextFeild.delegate = self
        geoActivityIndicator.hidden = true
        locationTextFeild.text = defaultText
        mediaURLTextFeild.text = defaultMediaText
        
        //Hide items for media step
        mapView.hidden = true
        mediaURLTextFeild.hidden = true
        submitButton.backgroundColor = UIColor.whiteColor()
        
        //Configure tap recognizer to dismiss the keybaord
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        
        //Configure UI for the submit button
        submitButton.backgroundColor = UIColor(white: 1, alpha: 0.6)
        submitButton.layer.cornerRadius = 5
        submitButton.layer.borderWidth = 1
        submitButton.layer.borderColor = forestGreen.CGColor
    }


    func geocodingCompleted(placemarks: [AnyObject]!, error: NSError!) {
        //Stop loading
        toggleLoading(false, indicator: geoActivityIndicator, view: view)
        
        if let placemark = placemarks?[0] as? CLPlacemark {
            
            //Save the location
            let latitude = placemark.location.coordinate.latitude
            let longitude = placemark.location.coordinate.longitude
            location = CLLocation(latitude: latitude, longitude: longitude)
            
            //Go to next step
            changeToMediaStep(location)
            
        } else {
            if error.localizedDescription.rangeOfString("2") != nil{
                alertError("The operation could not be completed.", viewController: self)
            } else {
                alertError("The location you entered could not be found.", viewController: self)
            }
        }
    }
    
    /* Center mapView to a location */
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    func changeToMediaStep(location: CLLocation){
        
        //Hide top label and location text field
        locationTextFeild.hidden = true
        topTitleLabel.hidden = true
        
        //Cancel Button
        cancelButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        
        //Configure header and footer views
        topView.backgroundColor = forestGreen
        bottomView.backgroundColor =  UIColor(white: 1, alpha: 0.5)
        
        //Update the submit button
        submitButton.setTitle("Submit", forState: .Normal)
        
        //Show to media url textField and the map view
        mediaURLTextFeild.hidden = false
        mapView.hidden = false
        
        //Create a pin from the geocoded locaiton and zoom to it
        let coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        var userPin = StudentPin(title: "\(UdacityClient.User.firstName) \(UdacityClient.User.lastName)", subtitle: "", coordinate: coordinate)
        mapView.addAnnotation(userPin)        
        centerMapOnLocation(location)
    }
    
}
