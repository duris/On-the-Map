//
//  TableViewController.swift
//  On the Map
//
//  Created by Ross Duris on 8/6/15.
//  Copyright (c) 2015 duris.io. All rights reserved.
//

import UIKit

class TableViewController: SharedViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var studentTableView: UITableView!
    @IBOutlet weak var tableActivityIndicator: UIActivityIndicatorView!
    var students = [StudentInformation]()

    override func viewDidLoad() {
        super.viewDidLoad()        
        
        // Configure table delegates
        studentTableView.dataSource = self
        studentTableView.delegate = self    
        
        // Get students from Parse
        loadStudentData()
        
        // Configure navigation items
        configureNavBarUI()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath:
            indexPath) as! UITableViewCell
        
        //Configure the cell
        cell.textLabel?.text = "\(students[indexPath.row].firstName) \(students[indexPath.row].lastName)"
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //Open students media URL
        let url = students[indexPath.row].mediaURL
        handleURL(url)
    }
    
    func refresh() {
        loadStudentData()
    }
    
    func loadStudentData(){
        //Start loading
        toggleLoading(true, indicator: tableActivityIndicator, view: view)
        ParseClient.sharedInstance().getStudentLocations() { (success, errorString) in
            if success {
                //Get students and update the table
                self.students = ParseClient.studentLocations
                dispatch_async(dispatch_get_main_queue()) {
                    self.studentTableView.reloadData()
                }
            } else {
                self.alertError("\(errorString)", viewController: self)
            }
            //Stop loading
            self.toggleLoading(false , indicator: self.tableActivityIndicator, view: self.view)
        }
    }
}
