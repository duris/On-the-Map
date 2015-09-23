//
//  LoginViewController.swift
//  On the Map
//
//  Created by Ross Duris on 8/4/15.
//  Copyright (c) 2015 duris.io. All rights reserved.
//

import UIKit

class LoginViewController: SharedViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var headerTextLabel: UILabel!
    @IBOutlet weak var loginActivityIdicator: UIActivityIndicatorView!
    let animation = CABasicAnimation(keyPath: "position")
    
    var keyboardAdjusted = false
    var lastKeyboardOffset : CGFloat = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
                
        // Configure Activity Indicator 
        loginActivityIdicator.hidden = true
        
        // Configure User Interface
        configureLoginUI()
        
    }

    override func viewWillAppear(animated: Bool) {
        addKeyboardDismissRecognizer()
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        removeKeyboardDismissRecognizer()
        unsubscribeToKeyboardNotifications()
    }

    @IBAction func loginButtonTouch() {
        //Start loading
        toggleLoading(true, indicator: loginActivityIdicator, view: view)
        UdacityClient.sharedInstance().authenticateWithCredentials(usernameTextField.text, password: passwordTextField.text, hostViewController: self) { (success, errorString) in
            if success {
                self.completeLogin()
            } else {
                self.alertError(errorString!, viewController: self)
            }
            //Stop loading
            self.toggleLoading(false, indicator: self.loginActivityIdicator, view: self.view)
        }
    }
    
    func completeLogin() {
        //Open the TabBarController
        dispatch_async(dispatch_get_main_queue()) {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }

    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if keyboardAdjusted == false {
            lastKeyboardOffset = getKeyboardHeight(notification) / 2
            view.superview?.frame.origin.y -= lastKeyboardOffset
            keyboardAdjusted = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if keyboardAdjusted == true {
            view.superview?.frame.origin.y += lastKeyboardOffset
            keyboardAdjusted = false
        }
    }
    
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }

    @IBAction func signUp(){
        //Open Udactiy sign up page
        let url = NSURL(string: "https://www.udacity.com/account/auth#!/signup")
        UIApplication.sharedApplication().openURL(url!)
    }

    //User interface concepts from Udacity ios-networking course
    func configureLoginUI() {
        
        // Configure background gradient
        self.view.backgroundColor = UIColor.clearColor()
        let colorTop = UIColor(red: 93/355, green: 170/255, blue: 183/355, alpha: 1.0).CGColor
        let colorBottom = UIColor(red: 73/355, green: 150/255, blue: 163/355, alpha: 1.0).CGColor
        var backgroundGradient = CAGradientLayer()
        backgroundGradient.colors = [colorTop, colorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        self.view.layer.insertSublayer(backgroundGradient, atIndex: 0)
        
        // Configure header text label
        headerTextLabel.font = UIFont(name: "AvenirNext-Medium", size: 24.0)
        headerTextLabel.textColor = UIColor.whiteColor()
        
        // Configure email textfield
        let emailTextFieldPaddingViewFrame = CGRectMake(0.0, 0.0, 13.0, 0.0)
        let emailTextFieldPaddingView = UIView(frame: emailTextFieldPaddingViewFrame)
        
        // Configure username textfield
        usernameTextField.leftView = emailTextFieldPaddingView
        usernameTextField.leftViewMode = .Always
        usernameTextField.font = UIFont(name: "AvenirNext-Medium", size: 17.0)
        usernameTextField.backgroundColor = UIColor(red: 143/355, green: 210/255, blue: 233/355, alpha:1.0)
        usernameTextField.textColor = forestGreen
        usernameTextField.attributedPlaceholder = NSAttributedString(string: usernameTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        usernameTextField.tintColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
        
        // Configure password textfield
        let passwordTextFieldPaddingViewFrame = CGRectMake(0.0, 0.0, 13.0, 0.0);
        let passwordTextFieldPaddingView = UIView(frame: passwordTextFieldPaddingViewFrame)
        passwordTextField.leftView = passwordTextFieldPaddingView
        passwordTextField.leftViewMode = .Always
        passwordTextField.font = UIFont(name: "AvenirNext-Medium", size: 17.0)
        passwordTextField.backgroundColor = UIColor(red: 143/355, green: 210/255, blue: 233/355, alpha:1.0)
        passwordTextField.textColor = forestGreen
        passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        passwordTextField.tintColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
        
        // Configure login button
        loginButton.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 17.0)
        loginButton.backgroundColor = forestGreen
        loginButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        
        // Configure tap recognizer
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
    }
}

