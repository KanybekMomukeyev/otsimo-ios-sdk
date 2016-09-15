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
import Kingfisher

class AllGamesViewController: UITableViewController {
    
    var games: [Game] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        otsimo.getAllGames("") {game, done, error in
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    func updateCell(_ cell: GameTableCellView, game: Game) {
        game.getManifest() {man, error in
            if let m = man {
                cell.titlLabel?.text = m.localVisibleName
                cell.versionLabel?.text = m.version
                cell.imageLabel.kf_setImage(with: NSURL(string: m.localIcon) as? Resource )
            } else {
                print("failed to get manifes")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "game_cell_reuse_identifier", for: indexPath) as! GameTableCellView
        
        let game = games[indexPath.row]
        updateCell(cell, game: game)
        return cell
    }
    
    fileprivate var selectedGame: Game?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let game = games[indexPath.row]
        selectedGame = game
        performSegue(withIdentifier: "gameinfotest", sender: tableView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let id = segue.identifier {
            if id == "gameinfotest" {
                let gic = segue.destination as! GameInfoViewController
                gic.game = selectedGame
            }
        }
    }
}
