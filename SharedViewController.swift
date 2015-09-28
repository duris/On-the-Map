//
//  SharedViewController.swift
//  On the Map
//
//  Created by Ross Duris on 9/21/15.
//  Copyright (c) 2015 duris.io. All rights reserved.
//

import UIKit

class SharedViewController: UIViewController {

    /* Universal tap recognizer */
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    /* Main app color */
    let forestGreen = UIColor(red: 43/355, green: 110/255, blue: 123/355, alpha:1.0)
    
    
    /*
    //
    //  Toggle the activity indicator and adjust the views appearance
    //
    */
    func toggleLoading(active: Bool, indicator: UIActivityIndicatorView, view: UIView){
        dispatch_async(dispatch_get_main_queue()) {
            if active {
                indicator.hidden = false
                indicator.startAnimating()
                view.opaque = false
                view.alpha = 0.6
            } else {
                indicator.hidden = true
                indicator.stopAnimating()
                view.opaque = true
                view.alpha = 1.0            
            }
        }
    }
    
    
    
    /*
    //
    //  Present an error message in an alert
    //
    */
    func alertError(message: String, viewController: UIViewController) {
        dispatch_async(dispatch_get_main_queue()) {
            let alertController = UIAlertController(title: .None, message:
                message, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            viewController.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    
    
    //----------------------------//
    //  Note to Udacity Reviewer
    /*
        Some of following could be placed into another shared view controller as it's not being used by all of the controllers. I was not sure if it was a neccessary abstraction. Any input? Thanks, Ross
    */
    //
    //----------------------------//
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func addKeyboardDismissRecognizer() {
        view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    

    func configureNavBarUI(){
        
        //Configure logout button
        let logoutButton =  UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain,
            target: self, action: "logoutUser")
        logoutButton.tintColor = forestGreen
        navigationItem.leftBarButtonItem = logoutButton
        
        //Configure pin button
        let pinButton = UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: "pinButtonTouch")
        pinButton.tintColor = forestGreen
        
        //Configure refresh button
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refresh")
        refreshButton.tintColor = forestGreen
        navigationItem.rightBarButtonItems = [pinButton, refreshButton]
    }
    
    
    //Logout user
    func logoutUser() {
        UdacityClient.sharedInstance().logout(self)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Open information posting view or alert if a location already exists
    func pinButtonTouch() {
        ParseClient.sharedInstance().queryStudentLocation(UdacityClient.User.uniqueKey) { (success, errorString) in
            if errorString != nil {
                self.alertError(errorString, viewController: self)
            } else if success {
                self.existingLocationAlert(self)
            } else {
                self.openInformationPostingView()
            }
        }
    }
    
    //Open a new InformationPostingViewController
    func openInformationPostingView(){
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InformationPostingViewController") as! InformationPostingViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    //Alert to user if they already have a location posted
    func existingLocationAlert(view:UIViewController){
        dispatch_async(dispatch_get_main_queue()) {
            let alertController = UIAlertController(title: .None, message:
                "A location for \(UdacityClient.User.firstName) \(UdacityClient.User.lastName) already exists. Would you like to overwrite it?", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.Default,handler: { (actionSheetController) -> Void in
                self.openInformationPostingView()
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default,handler: nil))
            view.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    
    /* Check for a valid URL */
    func handleURL(url: String) {
        print(url, terminator: "")
        if url.rangeOfString("http") != nil{
            openLink(NSURL(string: url)!)
        } else {
            if url.rangeOfString("www") != nil {
                let newURL = "http://\(url)"
                openLink(NSURL(string: newURL)!)
            } else {
               alertError("Invalid link", viewController: self)
            }
            
        }
    }
    
    /* Attemp to open url */
    func openLink(link:NSURL){
        if UIApplication.sharedApplication().canOpenURL(link) {
            UIApplication.sharedApplication().openURL(link)
        } else {
            alertError("Invalid link", viewController: self)
        }
    }


}
