//
//  ChildListViewController.swift
//  OtsimoSDK_Example
//
//  Created by Sercan Değirmenci on 07/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import UIKit
import OtsimoSDK
import OtsimoApiGrpc

class ChildListViewController: UITableViewController {

    var childList: [OTSChild] = []
    var selectedChildId = ""
    var nextSegue = "getchildtest"
    override func viewDidLoad() {
        super.viewDidLoad()

        otsimo.getChildren() { res, err in
            switch (err) {
            case .None:
                self.childList.removeAll()
                self.childList.appendContentsOf(res)
                self.tableView.reloadData()
                for i in 0 ..< self.childList.count {
                    print("child[\(i)] is \(self.childList[i]) and parentID: \(self.childList[i].parentId)")
                }
            default:
                print("getting child list error \(err)")
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return childList.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("child_list_reuse_identifier", forIndexPath: indexPath)
        let child = childList[indexPath.row]
        cell.textLabel?.text = "\(child.firstName) \(child.lastName)"
        cell.detailTextLabel?.text = child.id_p
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let child = childList[indexPath.row]
        selectedChildId = child.id_p
        print("clicked on '\(selectedChildId)'")
        performSegueWithIdentifier(nextSegue, sender: tableView)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let id = segue.identifier {
            if id == "getchildtest" {
                let cic = segue.destinationViewController as! ChildViewController
                cic.childIdWillFetch = selectedChildId
                print("will fetch '\(selectedChildId)'")
            }
        }
    }
}
