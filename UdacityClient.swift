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
    
    /* Udacity User */
    struct User {
        static var uniqueKey = ""
        static var firstName = ""
        static var lastName = ""
        
    }
    
    /* Initialize the session */
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    
    
    
    /*
    /
    / Authenticate with Udacity using the entered username and password
    /
    */
    func authenticateWithCredentials(username:String, password:String, hostViewController: UIViewController, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil  {
                completionHandler(success: false, errorString: "\(error!.localizedDescription)")
                return
            } else {
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5 ))
                print(NSString(data: newData, encoding: NSUTF8StringEncoding))
                //var parsingError: NSError? = nil
                let parsedResult = (try! NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments)) as! NSDictionary
                
                if let account = parsedResult["account"] as? [String:AnyObject],
                    let registered = account["registered"] as? Bool,
                    let key = account["key"] as? String {
                        User.uniqueKey = key as String
                        self.getUserData(key) { (success, errorString) in
                            if success {
                                completionHandler(success: true, errorString:nil)
                            } else {
                                completionHandler(success: false, errorString: errorString)
                            }
                        }
                } else if let status = parsedResult["status"] as? Int {
                    if status == 400 {
                            completionHandler(success: false, errorString: "Username or password is empty.")
                    } else if status == 403 {
                            completionHandler(success: false, errorString: "Account not found or invalid credentials.")
                    }
                } else {
                    completionHandler(success: false, errorString:"Could not complete login. There was an error with the server.")
                }
            }
        }
        task.resume()
    }
    
    

    
    /*
    /
    / Send a HTTP Delete request to the server and end the current session
    /
    */
    func logout(hostViewController: UIViewController) {
    
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in (sharedCookieStorage.cookies as [NSHTTPCookie]!) {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                
                return
            } else {
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
                print(NSString(data: newData, encoding: NSUTF8StringEncoding))
            }
        }
        task.resume()
    }
    
    
    
    /*
    /
    / Get user data from Udactiy and store it in the User struct
    /
    */
    func getUserData(key:String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(key)")!)
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, errorString: "\(error!.localizedDescription)")
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            //var parsingError: NSError? = nil
            let parsedResult = (try! NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments)) as! NSDictionary
        
            if let user = parsedResult["user"] as? NSDictionary {
                if let firstName = user["first_name"] as? String,
                    let lastName = user["last_name"] as? String {
                        User.firstName = firstName
                        User.lastName = lastName
                        completionHandler(success: true, errorString: nil)
                    }
                else {
                        completionHandler(success: false, errorString: "Could not complete login. There was an error with the server.")
                }
            }
        }
        task.resume()
    }
    


    /* Shared Instance */
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
}
