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

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath:
            indexPath) as! UITableViewCell
        
        return cell
    }

    @IBAction func logout() {
        UdacityClient.sharedInstance().logout(self)
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! UIViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }
}
