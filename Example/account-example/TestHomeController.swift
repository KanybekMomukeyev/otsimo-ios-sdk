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

func watchCallback(_ event: OTSWatchEvent) {
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

    func onSessionStatusChanged(_ ses: Session?) {
        self.tableView.reloadData()
        let (_, e) = otsimo.startWatch(callback: watchCallback)
        print("Watch: \(e)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return testEntries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "test_reuse_identifier", for: indexPath as IndexPath)

        // Configure the cell...
        let test = testEntries[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = test.title
        if test.requiresAuth {
            if let auth = otsimo.session?.isAuthenticated {
                if auth {
                    cell.accessoryType = .disclosureIndicator
                    cell.textLabel?.textColor = UIColor.black
                } else {
                    cell.accessoryType = .none
                    cell.textLabel?.textColor = UIColor.gray
                }
            } else {
                cell.accessoryType = .none
                cell.textLabel?.textColor = UIColor.gray
            }
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let test = testEntries[(indexPath as NSIndexPath).row]
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
            performSegue(withIdentifier: test.segmentName, sender: tableView)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let id = segue.identifier {

            otsimo.analytics.customEvent(event: "test:scene", payload: ["identifier": id as AnyObject])

            if id == "editchildgamestest" {
                let cic = segue.destination as! ChildListViewController
                cic.nextSegue = "getchildtest"
            } else if id == "getchildlisttest" {
                let cic = segue.destination as! ChildListViewController
                cic.nextSegue = "getchildtest"
            }
        }
    }
}
