//
//  ListViewController.swift
//  On the Map
//
//  Created by Ross Duris on 8/6/15.
//  Copyright (c) 2015 duris.io. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var studentTableView: UITableView!
    var students = [ParseStudent]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        studentTableView.dataSource = self
        studentTableView.delegate = self
        
        /* Get students data */
        ParseClient.sharedInstance().getStudentData() { (students, errorString) in
            self.students = students
            dispatch_async(dispatch_get_main_queue()) {
                self.studentTableView.reloadData()
            }
        }
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return students.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath:
            indexPath) as! UITableViewCell
        
        /* Set the cells text label */
        cell.textLabel?.text = "\(students[indexPath.row].firstName) \(students[indexPath.row].lastName)"
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        /* Get the students media URL */
        let url = students[indexPath.row].mediaURL
        
        if url != "" {
             /* Open students media URL in Safari */
             UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        }
    }

    @IBAction func logout() {
        /* Logout the user and present the login view */
        UdacityClient.sharedInstance().logout(self)
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! UIViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }
}
