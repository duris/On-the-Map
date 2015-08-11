//
//  ParseStudent.swift
//  On the Map
//
//  Created by Ross Duris on 8/11/15.
//  Copyright (c) 2015 duris.io. All rights reserved.
//

struct ParseStudent {
    
    var firstName = ""
    var lastName = ""
    var latitude = 0.00
    var longitude = 0.00
    var mediaURL = ""
    
    /* Construct a ParseStudent from a dictionary */
    init(dictionary: [String : AnyObject]) {
        
        firstName = dictionary["firstName"] as! String
        lastName = dictionary["lastName"] as! String
        latitude = dictionary["latitude"] as! Double
        longitude = dictionary["longitude"] as! Double
        mediaURL = dictionary["mediaURL"] as! String
    }
    
    /* Helper: Given an array of dictionaries, convert them to an array of ParseStudent objects */
    static func studentsFromResults(results: [[String : AnyObject]]) -> [ParseStudent] {
        var students = [ParseStudent]()
        
        for result in results {
            students.append(ParseStudent(dictionary: result))
        }
        
        return students
    }
}
