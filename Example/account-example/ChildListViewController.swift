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
            case .none:
                self.childList.removeAll()
                self.childList.append(contentsOf: res)
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return childList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "child_list_reuse_identifier", for: indexPath)
        let child = childList[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = "\(child.firstName) \(child.lastName)"
        cell.detailTextLabel?.text = child.id_p
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let child = childList[(indexPath as NSIndexPath).row]
        selectedChildId = child.id_p
        print("clicked on '\(selectedChildId)'")
        performSegue(withIdentifier: nextSegue, sender: tableView)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let id = segue.identifier {
            if id == "getchildtest" {
                let cic = segue.destination as! ChildViewController
                cic.childIdWillFetch = selectedChildId
                print("will fetch '\(selectedChildId)'")
            }
        }
    }
}
