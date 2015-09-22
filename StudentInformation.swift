//
//  StudentInformation.swift
//  On the Map
//
//  Created by Ross Duris on 8/12/15.
//  Copyright (c) 2015 duris.io. All rights reserved.
//


struct StudentInformation {
    
    /* Parse student object properties */
    var firstName = ""
    var lastName = ""
    var latitude = 0.00
    var longitude = 0.00
    var mediaURL = ""
    var mapString = ""
    var uniqueKey = ""
    
    /* Construct a StudentInformation object from a dictionary */
    init(dictionary: [String : AnyObject]) {
        firstName = dictionary["firstName"] as! String
        lastName = dictionary["lastName"] as! String
        latitude = dictionary["latitude"] as! Double
        longitude = dictionary["longitude"] as! Double
        mediaURL = dictionary["mediaURL"] as! String
        mapString = dictionary["mapString"] as! String
        uniqueKey = dictionary["uniqueKey"] as! String
    }
    
    /* Helper: Given an array of dictionaries, convert them to an array of StudentInformation objects */
    static func studentsFromResults(results: [[String : AnyObject]]) -> [StudentInformation] {
        var students = [StudentInformation]()
        
        for result in results {
            students.append(StudentInformation(dictionary: result))
        }
        
        return students
    }
}
