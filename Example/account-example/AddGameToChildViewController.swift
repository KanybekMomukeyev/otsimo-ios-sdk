//
//  AddGameToChildViewController.swift
//  OtsimoSDK_Example
//
//  Created by Sercan Değirmenci on 01/02/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import UIKit
import OtsimoSDK
import Haneke
import OtsimoApiGrpc

class AddGameToChildViewController: UIViewController {
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    internal var game: Game?
    internal var childList: [OTSChild] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        otsimo.getChildren() {cl, err in
            self.childList.appendContentsOf(cl)
            self.tableView.reloadData()
        }
        if let g = game {
            g.getManifest(initGame)
        }
    }
    
    func initGame(gm: GameManifest?, err: OtsimoError) -> Void {
        if let g = gm {
            iconImageView.hnk_setImageFromURL(NSURL(string: g.localIcon)!)
            infoLabel.text = "\(g.localVisibleName)\nselect childs to add game"
        }
    }
    
    @IBAction func addPressed(sender: AnyObject) {
        for i in tableView.indexPathsForSelectedRows! {
            addGameToChild(childList[i.row])
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelTouched(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addGameToChild(child: OTSChild) {
        otsimo.addGameToChild(game!.id, childID: child.id_p,
            index: Int32(child.gamesArray.count),
            settings: game!.defaultSettings()) {res in
            print("add game finished with \(res)")
        }
    }
}

extension AddGameToChildViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return childList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("add_game_to_child_cell", forIndexPath: indexPath)
        
        // Configure the cell...
        let c = childList[indexPath.row]
        cell.textLabel!.text = "\(c.firstName) \(c.lastName)"
        cell.accessoryType = UITableViewCellAccessoryType.None;
        return cell
    }
}

extension AddGameToChildViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        cell.accessoryType = UITableViewCellAccessoryType.Checkmark
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        cell.accessoryType = UITableViewCellAccessoryType.None
    }
}

