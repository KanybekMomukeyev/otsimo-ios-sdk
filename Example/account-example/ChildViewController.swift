//
//  ChildViewController.swift
//  OtsimoSDK_Example
//
//  Created by Sercan Değirmenci on 02/02/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import UIKit
import OtsimoApiGrpc
import OtsimoSDK
import Haneke

class ChildViewController: UITableViewController {
    
    var childIdWillFetch: String = ""
    
    var infos: [String] = []
    var targetChild: OTSChild?
    var gameEntries: [ChildGame] = []
    var fetchedGames: [ChildGame] = []
    var selectedGameEntry: ChildGame?
    override func viewDidLoad() {
        super.viewDidLoad()
        otsimo.getChild(childIdWillFetch, handler: getChildHandler)
    }
    
    func getChildHandler(child: OTSChild?, err: OtsimoError) {
        infos.removeAll()
        targetChild = child
        if let child = child {
            infos.append("name: \(child.firstName) \(child.lastName)")
            infos.append("id: \(child.id_p)")
            infos.append("parent: \(child.parentId)")
            infos.append("language: \(child.language)")
            if child.gender == OTSGender.Male {
                infos.append("gender: Male")
            } else if child.gender == OTSGender.Female {
                infos.append("gender: Female")
            }
            infos.append("active: \(child.active)")
            
            tableView.reloadData()
            
            gameEntries = child.getGames()
            for e in gameEntries {
                print("getting the game", e.gameID)
                e.initialize(true, initKeyValueStorage: true, handler: getGameHandler)
            }
        }
    }
    
    func getGameHandler(game: ChildGame, error: OtsimoError) {
        switch (error) {
        case .None:
            fetchedGames.append(game)
            tableView.reloadData()
        default:
            print("failed to fetch \(game.gameID) error:\(error)")
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return infos.count
        } else {
            return fetchedGames.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("child_info_cell", forIndexPath: indexPath)
            
            cell.textLabel?.text = infos[indexPath.row]
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("child_game_cell", forIndexPath: indexPath)
            cell.textLabel?.text = "loading..."
            let game = fetchedGames[indexPath.row]
            if let man = game.manifest {
                cell.textLabel?.text = man.localVisibleName
                if let url = NSURL(string: man.localIcon) {
                    cell.imageView!.hnk_setImageFromURL(url)
                }
            }
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if section == 0 {
            return "info"
        } else {
            return "games"
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            return
        }
        selectedGameEntry = fetchedGames[indexPath.row]
        performSegueWithIdentifier("show_child_game_entry", sender: self)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "show_child_game_entry" {
            let cgc = segue.destinationViewController as! ChildGameController
            cgc.childGame = selectedGameEntry
        }
    }
}
