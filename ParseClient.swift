//
//  ParseClient.swift
//  On the Map
//
//  Created by Ross Duris on 8/4/15.
//  Copyright (c) 2015 duris.io. All rights reserved.
//

import Foundation

class ParseClient : NSObject {
    
    let applicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    let restAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    
    func getStudentData(completionHandler: (students: [StudentInformation], errorString: String?) -> Void) {
        
        /* Create the request */
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.addValue(applicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(restAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        
        /* Configure the request */
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                return
            }

            /* Parse the data */
            var parsingError: NSError? = nil
            let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
            
            /* Use the data */
            if let results = parsedResult["results"] as? [[String : AnyObject]] {
                
                /* Set the results in the completion handler */
                completionHandler(students: StudentInformation.studentsFromResults(results), errorString: nil)
            } else {
                println("Could not find results in \(parsedResult)")
            }
        }
        /* Start the request */
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
