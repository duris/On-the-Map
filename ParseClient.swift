//
//  ParseClient.swift
//  On the Map
//
//  Created by Ross Duris on 8/4/15.
//  Copyright (c) 2015 duris.io. All rights reserved.
//

import UIKit
import Foundation

class ParseClient : NSObject {
    
    /* Shared session */
    var session: NSURLSession

    /* Parse AppID and RestAPIKey */
    static let AppID : String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    static let RestAPIKey : String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    
    static var locationId: String = ""

    /* Parse student locations */
    static var studentLocations: [StudentInformation] = []
    
    /* Initialize the session */
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }

    
    
    /*
    /
    / Get the student location objects and save them in an array
    /
    */
    func getStudentLocations(completionHandler: (success: Bool, errorString: String!) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation?limit=100&order=-updatedAt")!)
        request.addValue(ParseClient.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseClient.RestAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, errorString: "\(error.localizedDescription)")
                return
            }
            var parsingError: NSError? = nil
            let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary

            if let results = parsedResult["results"] as? [[String : AnyObject]] {
                ParseClient.studentLocations = StudentInformation.studentsFromResults(results)
                completionHandler(success: true, errorString: nil)
            } else {
                completionHandler(success: false, errorString: "Could not complete download. There was an error with the server.")
            }
        }
        task.resume()
    }
    
    
    
    /*
    /
    / Post a new student location
    /
    */
    func postStudentLocation(student:StudentInformation, completionHandler: (success: Bool, errorString: String!) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue(ParseClient.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseClient.RestAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(student.uniqueKey)\", \"firstName\": \"\(student.firstName)\", \"lastName\": \"\(student.lastName)\",\"mapString\": \"\(student.mapString)\", \"mediaURL\": \"\(student.mediaURL)\",\"latitude\": \(student.latitude), \"longitude\": \(student.longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, errorString: "\(error.localizedDescription)")
                return
            } else {
                println(NSString(data: data, encoding: NSUTF8StringEncoding))
                completionHandler(success: true, errorString: nil)                
            }
        }
        task.resume()
    }
    
    
    
    /*
    /
    / Query for an existing student location
    /
    */
    func queryStudentLocation(uniqueKey: String, completionHandler: (success: Bool, errorString: String!) -> Void) {
        let urlString = "https://api.parse.com/1/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(uniqueKey)%22%7D"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.addValue(ParseClient.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseClient.RestAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, errorString: error.localizedDescription)
                return
            }
            
            if let studentData = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: nil) as? NSDictionary {
                if let results = studentData["results"] as? [NSDictionary] {
                    for item in results{
                        if let objectId = item["objectId"] as? String! {
                            ParseClient.locationId = objectId!
                            completionHandler(success: true, errorString: nil)
                        } else {
                            completionHandler(success: false, errorString: nil)
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    
    
    /*
    /
    / Update an existing student location
    /
    */
    func updateStudentLocation(objectId: String, student: StudentInformation, completionHandler: (success: Bool, errorString: String!) -> Void) {
        
        let urlString = "https://api.parse.com/1/classes/StudentLocation/\(objectId)"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "PUT"
        request.addValue(ParseClient.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseClient.RestAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(student.uniqueKey)\", \"firstName\": \"\(student.firstName)\", \"lastName\": \"\(student.lastName)\",\"mapString\": \"\(student.mapString)\", \"mediaURL\": \"\(student.mediaURL)\",\"latitude\": \(student.latitude), \"longitude\": \(student.longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, errorString: error.localizedDescription)
                return
            } else {
                println(NSString(data: data, encoding: NSUTF8StringEncoding))
                completionHandler(success: true, errorString: nil)
            }
        }
        task.resume()
    }
    
    
    
    /* Shared Instance */
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
}
