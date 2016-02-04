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
    var games: [Game] = []
    var targetChild: OTSChild?
    var gameEntries: [OTSChildGameEntry] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        otsimo.getChild(childIdWillFetch, handler: getChildHandler)
    }
    
    func getChildHandler(child: OTSChild?, err: OtsimoError) {
        infos.removeAll()
        games.removeAll()
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
            
            gameEntries = child.gamesArray as AnyObject as! [OTSChildGameEntry]
            for e in gameEntries {
                print("getting the game", e.id_p, e.description)
                otsimo.getGame(e.id_p, handler: getGameHandler)
            }
        }
    }
    
    func getGameHandler(game: Game?, error: OtsimoError) {
        if let g = game {
            games.append(g)
            tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return infos.count
        } else {
            return games.count
        }
    }
    
    func updateCell(game: Game, cell: UITableViewCell) {
        game.getManifest() {man, err in
            if let man = man {
                cell.textLabel?.text = man.localVisibleName
                if let url = NSURL(string: man.localIcon) {
                    cell.imageView!.hnk_setImageFromURL(url)
                }
            }
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
            let game = games[indexPath.row]
            updateCell(game, cell: cell)
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
        print(games[indexPath.row].uniqueName, "pressed")
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
