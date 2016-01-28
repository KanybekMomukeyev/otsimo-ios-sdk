//
//  AllGamesViewController.swift
//  OtsimoSDK_Example
//
//  Created by Sercan Değirmenci on 25/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import UIKit
import OtsimoSDK
import OtsimoApiGrpc

class AllGamesViewController: UITableViewController {
    
    var games: [Game] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        otsimo.getAllGames() {game, done, error in
            if let f = game {
                self.games.append(f)
                self.tableView.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    func updateCell(cell: GameTableCellView, game: Game) {
        game.getManifest() {man, error in
            if let m = man {
                cell.titlLabel?.text = m.localVisibleName
                cell.versionLabel?.text = m.version
                cell.imageLabel.hnk_setImageFromURL(NSURL(string: m.localIcon)!)
            } else {
                print("failed to get manifes")
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("game_cell_reuse_identifier", forIndexPath: indexPath) as! GameTableCellView
        
        let game = games[indexPath.row]
        updateCell(cell, game: game)
        return cell
    }
    
    private var selectedGame: Game?
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let game = games[indexPath.row]
        selectedGame = game
        performSegueWithIdentifier("gameinfotest", sender: tableView)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let id = segue.identifier {
            if id != "gameinfotest" {
                return
            }
        } else {
            return
        }
        let gic = segue.destinationViewController as! GameInfoViewController
        gic.game = selectedGame
    }
}
