//
//  TestHomeController.swift
//  OtsimoSDK_Example
//
//  Created by Sercan Değirmenci on 05/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import UIKit
import OtsimoSDK
import OtsimoApiGrpc

func watchCallback(event:OTSWatchEvent){
    print("Watch: \(event)")
}

class TestHomeController: UITableViewController {
    var testEntries: [ApiTest] = apiTestScenes
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        otsimo.sessionStatusChanged = onSessionStatusChanged
    }
    
    func onSessionStatusChanged(ses: Session?) {
        self.tableView.reloadData()
        let (_,e) = otsimo.startWatch(watchCallback)
        print("Watch: \(e)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return testEntries.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("test_reuse_identifier", forIndexPath: indexPath)
        
        // Configure the cell...
        let test = testEntries[indexPath.row]
        cell.textLabel?.text = test.title
        if test.requiresAuth {
            if let auth = otsimo.session?.isAuthenticated {
                if auth {
                    cell.accessoryType = .DisclosureIndicator
                    cell.textLabel?.textColor = UIColor.blackColor()
                } else {
                    cell.accessoryType = .None
                    cell.textLabel?.textColor = UIColor.grayColor()
                }
            } else {
                cell.accessoryType = .None
                cell.textLabel?.textColor = UIColor.grayColor()
            }
        }
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let test = testEntries[indexPath.row]
        if test.requiresAuth {
            if let auth = otsimo.session?.isAuthenticated {
                if !auth {
                    return
                }
            } else {
                return
            }
        }
        if let h = test.handle {
            h()
            tableView.reloadData()
        } else {
            performSegueWithIdentifier(test.segmentName, sender: tableView)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let id = segue.identifier {
            
            otsimo.analytics.customEvent("test:scene", payload: ["identifier":id])
            
            if id == "editchildgamestest" {
                let cic = segue.destinationViewController as! ChildListViewController
                cic.nextSegue = "getchildtest"
            } else if id == "getchildlisttest" {
                let cic = segue.destinationViewController as! ChildListViewController
                cic.nextSegue = "getchildtest"
            }
        }
    }
}
