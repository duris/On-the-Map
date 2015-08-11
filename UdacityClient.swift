//
//  UdacityClient.swift
//  On the Map
//
//  Created by Ross Duris on 8/4/15.
//  Copyright (c) 2015 duris.io. All rights reserved.
//

import UIKit
import Foundation

class UdacityClient : NSObject {
    
    /* Shared session */
    var session: NSURLSession
    
    /* Parsing Error */
    var parsingError: String!
    
    /* Authentication state */
    var sessionID : String? = nil
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    /* Authenticate with Udacity */
    func authenticateWithCredentials(username:String, password:String, hostViewController: UIViewController, completionHandler: (success: Bool, sessionID: String?, errorString: String?) -> Void) {
        
        /* Configure the request */        
        /* Note: Without www in the url the request returns registered as false */
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        /* Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil  {
                //Handle error
                return
            } else {
                
                /* Subset response data */
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5 ))
                
                /* Parse the data */
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                /* Use the data! */
                if let status = parsedResult["status"] as? Int {
                    if status == 400 {
                        dispatch_async(dispatch_get_main_queue()) {
                            completionHandler(success: false, sessionID: nil, errorString: "Username or password is empty.")
                        }
                    } else if status == 403 {
                        dispatch_async(dispatch_get_main_queue()) {
                            completionHandler(success: false, sessionID: nil, errorString: "Account not found or invalid credentials.")
                        }
                    }
                } else {
                    if let account = parsedResult["account"] as? [String:AnyObject] {
                        if let registered = account["registered"] as? Bool {
                            if registered {
                                if let userID = account["key"] as? String {
                                    println("The user ID is \(userID)")
                                    self.getUserData(userID) { (fullName, errorString) in
                                        println("The user is \(fullName!)")
                                    }
                                }
                                if let session = parsedResult["session"] as? NSDictionary {
                                    if let sessionID = session["id"] as? String {
                                        completionHandler(success: true, sessionID: sessionID, errorString: nil)
                                    } else {
                                        println("Could not find id in \(session)")
                                    }
                                } else {
                                    println("Could not find session in \(parsedResult)")
                                }
                            } else {
                                println("Account not registered.")
                            }
                        } else {
                            println("Could not find registered in \(account)")
                        }
                    } else {
                        println("Could not find account in \(parsedResult)")
                    }
                }
            }
        }
        /* Start the request */
        task.resume()
    }
    
    func logout(hostViewController: UIViewController) {
        
        /* Configure the request */
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        
        /* Shared cookie storage */
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        /* Check cookie name for current state */
        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        
        /* Update the cookie name */
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        /* Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                // Handle error…
                return
            } else {
                /* Subset response data */
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                println(NSString(data: newData, encoding: NSUTF8StringEncoding))
            }
        }
        /* Start the request */
        task.resume()
    }
    
    func getUserData(userID:String, completionHandler: (fullName: String?, errorString: String?) -> Void) {
        
        /* Configure the request */
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(userID)")!)

        /* Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                return
            }
            
            /* Subset response data */
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            
            /* Parse the data */
            var parsingError: NSError? = nil
            let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
            
            /* Use the data */
            if let user = parsedResult["user"] as? NSDictionary {
                completionHandler(fullName: self.getFullName(user), errorString: nil)
            }
            
        }
        task.resume()
    }
    
    func getFullName(user: NSDictionary) -> String {
        var name: String!
        if let lastName = user["last_name"] as? String {
            if let firstName = user["first_name"] as? String {
                name = firstName + " " + lastName
            }
        }
        return name
    }

    /* Shared Instance */
    class func sharedInstance() -> UdacityClient {
        
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }

}
